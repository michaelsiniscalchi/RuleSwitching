clearvars;

root = 'J:\Data & Analysis\Rule Switching\Data\190503 M62 Ruleswitching';
roi_dir = fullfile(root,'ROI_190503 M62 Ruleswitching_regDS1.tif');
raw_dir = fullfile(root,'raw');
reg_dir = fullfile(root,'registered');
mat_dir = fullfile(root,'MAT');
create_dirs(mat_dir);

flist = dir(fullfile(raw_dir,'*.tif'));
for i = 1:numel(flist)
    raw_paths{i} = fullfile(raw_dir,flist(i).name);
    reg_name = ['NRMC_' flist(i).name];
    tiff_path{i} = fullfile(reg_dir,reg_name); %Name of registered stack is NRMC_(+raw filename) 
    mat_path{i} = fullfile(mat_dir,reg_name(1:end-4));
end

%%

stackInfo = get_stackInfo(raw_paths);

borderWidth = 3;
[stack, cells ] = get_fluoData( roi_dir, tiff_path, mat_path );
[cells, masks] = calc_cellF(stack, cells, borderWidth);