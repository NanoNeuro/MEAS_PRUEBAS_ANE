import spikeinterface.full as si  # import core only
import spikeinterface.preprocessing as spre

from spikeinterface.sortingcomponents.peak_detection import detect_peaks

from typing import Tuple, List
from probeinterface import Probe

import random
import string

import numpy as np
import pandas as pd

import datetime as dt

import os





def load_recording_from_raw(root: str, sample_base: str, well: Tuple[int, int], time_samplings_to_mask: List[Tuple[float, float]]):

    traces_list = []
    channel_ids = []

    df = pd.read_csv(f'{root}/{sample_base}/{sample_base}.info', index_col=0, names=['index', 'value'], sep='\t')
    sampling_frequency = df.loc['SamplingFrequency', 'value']
    voltage_scale = np.abs(df.loc['VoltageScale', 'value'])

    # We choose 10 here because in 64-electrode MEAs the range would be up to 9. 
    # Since the time required for the non-existing electrodes is small, we don't mine using a larger number.
    for Erow in range(1,10):  
        for Ecol in range(1,10):
            filename = f'{root}/{sample_base}/{well[0]}-{well[1]}-{Erow}-{Ecol}_voltageRaw'
            is_txt, is_gzip = os.path.exists(f'{filename}.txt'), os.path.exists(f'{filename}.txt.gz') 

            if is_txt or is_gzip:
                channel_ids.append(f'{Erow}-{Ecol}')
                
                if is_txt:
                    list_voltages = np.loadtxt(f'{filename}.txt')
                elif is_gzip:
                    list_voltages = np.loadtxt(f'{filename}.txt.gz')

                traces_list.append(list_voltages)
            

    trace_array = np.asarray(traces_list).transpose() / voltage_scale

    for time_sampling in time_samplings_to_mask:
        t0 = int(time_sampling[0] * sampling_frequency)
        tf = int(time_sampling[1] * sampling_frequency)
        trace_array[t0:tf, :] = 0

    sample_recording = si.NumpyRecording(
        traces_list=[trace_array],
        sampling_frequency=sampling_frequency,
        channel_ids=np.asarray(channel_ids)
    )

    sample_recording.set_property('group', [0] * len(channel_ids))
    sample_recording.is_dumpable = True  # This is necessary for some options later, like spike sorting

    return sample_recording


def load_probe_recording(recording: si.NumpyRecording, type_MEAS: int, ):
    dist_multiplier = 350 if type_MEAS == 16 else 300
    circle_radius = 50

    channel_ids = recording.get_channel_ids()

    positions = np.zeros((len(channel_ids), 2), dtype=float)
    contact_vector = []
    for channel_idx, channel in enumerate(channel_ids):
        x_coord, y_coord = (int(channel.split('-')[0]) - 1) * dist_multiplier, (int(channel.split('-')[1]) - 1) * dist_multiplier
        positions[channel_idx, 1], positions[channel_idx, 0] = x_coord, y_coord
        
        contact_vector.append((0, x_coord,   y_coord, 'circle', circle_radius, '', '', channel_idx, 'um', 1., 0., 0., 1.))

    # later if we are using peak detection, we may need it
    recording.set_channel_locations(locations=positions)

    probe = Probe(ndim=2, si_units='um')
    probe.set_contacts(positions=positions, shapes='circle', shape_params={'radius': circle_radius})
    probe.device_channel_indices = np.arange(len(channel_ids))
    probe.create_auto_shape('rect')

    recording.set_probe(probe)


    # Create contact_vector
    dtypes=[('probe_index', '<i8'), ('x', '<f8'), ('y', '<f8'), ('contact_shapes', '<U64'), 
            ('radius', '<f8'), ('shank_ids', '<U64'), ('contact_ids', '<U64'), ('device_channel_indices', '<i8'), 
            ('si_units', '<U64'), ('plane_axis_x_0', '<f8'), ('plane_axis_x_1', '<f8'), ('plane_axis_y_0', '<f8'), 
            ('plane_axis_y_1', '<f8')]

    recording.set_property('contact_vector', np.asarray(contact_vector, dtype=dtypes))



def retrieve_peaks(root, sample_base, well):
    session_token = dt.datetime.now().strftime("%y-%m-%d") + '_' + \
                ''.join(random.choice(string.ascii_letters) for i in range(8)) + str(well[0]) + '-' + str(well[1])
    
    recording = load_recording_from_raw(root=root, sample_base=sample_base, well=well, time_samplings_to_mask=[])
    load_probe_recording(recording=recording, type_MEAS=16)
    
    recording_bin = recording.save(n_jobs=16, chunk_duration="1s", folder=f'tmp/bin_{session_token}')

    recording_f = spre.bandpass_filter(recording_bin, freq_min=300, freq_max=5000)

    recording_cmr = spre.common_reference(recording_f, reference='global', operator='median')

    noise_levels = si.get_noise_levels(recording_cmr, return_scaled=False)

    try:
        peaks = detect_peaks(recording_cmr,
                            method='locally_exclusive',
                            local_radius_um=450, 
                            detect_threshold=5,
                            noise_levels=noise_levels,
                            )
    except:
        peaks = detect_peaks(recording_cmr,
                            method='locally_exclusive',
                            radius_um=450,  # Argument changes for spike interface new version
                            detect_threshold=5,
                            noise_levels=noise_levels,
                            )
    
    list_peaks = []
    list_electrodes = []

    for i in range(16):
        list_peaks_i = [peak[0] / recording.sampling_frequency for peak in peaks if peak[1] == i]
        list_peaks += list_peaks_i

        el_x, el_y = i // 4, i % 4
        list_electrodes += [f'{el_x + 1}{el_y + 1}'] * len(list_peaks_i)

    os.system(f"rm -rf $PWD/tmp/bin_{session_token}")
    os.system(f"rmdir $PWD/tmp/bin_{session_token}")

    return list_peaks, list_electrodes