function filename = returnFilename(ROOT, SAVE_FOLDER, CRow, CCol, ERow, ECol)
    filename=strcat(ROOT, '\', SAVE_FOLDER, '\', ...
                        num2str(CRow), '-', num2str(CCol), '-', num2str(ERow), '-', num2str(ECol));
end

