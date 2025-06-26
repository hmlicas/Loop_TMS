function fig = plot_surf_map_all(face_l, vx_l, val_l, face_r, vx_r, val_r, cm, tar_pos)

fig = figure; 

hold on;

if ~isempty(cm)
    colormap(cm)
else
    cmap = colormap;
    cmap(1,:) = 230 / 255 * ones(1,3);
    colormap(cmap);    
end

trisurf(face_l, vx_l(:,1), vx_l(:,2), vx_l(:,3), val_l);
trisurf(face_r, vx_r(:,1), vx_r(:,2), vx_r(:,3), val_r);
%patch('Faces',face_l,'Vertices',vx_l,'FaceVertexCData',val_l,'FaceColor','flat');
%patch('Faces',face_r,'Vertices',vx_r,'FaceVertexCData',val_r,'FaceColor','flat');

view(0, 90);
axis equal;
camlight(0, 0);
axis vis3d off;
lighting phong; 
material dull;
shading interp; % flat;

if ~isempty(tar_pos)
    for tpi=1:size(tar_pos,1)
        tpi_str = num2str(tpi); 
        tpi_str_coord = [num2str(tpi), ': ', sprintf('%0.2f', tar_pos(tpi,1)), ...
                         ', ', sprintf('%0.2f', tar_pos(tpi,2)), ', ', sprintf('%0.2f', tar_pos(tpi,3))];
        
        if tpi==1
            tpi_annot = tpi_str_coord;
        else
            tpi_annot = [tpi_annot, newline, tpi_str_coord];
        end
        
        ipos = tar_pos(tpi,:) * 1.5;
        ix = [tar_pos(tpi,1), ipos(1)];
        iy = [tar_pos(tpi,2), ipos(2)];
        iz = [tar_pos(tpi,3), ipos(3)];
        line(ix, iy, iz, 'Color', 'red');
        
        ipos2 = ipos * 1.1;
        text(ipos2(1), ipos2(2), ipos2(3), tpi_str, 'Color', 'red', 'FontSize', 12);
    end
    
    annot = annotation('textbox', [0.02, 0.5, .3, .3], 'String', tpi_annot, 'FitBoxToText', 'on');
    annot.FontSize = 8;
    annot.Color = 'k';
end
