Flist = dir();
Flist = Flist(arrayfun(@(X) Flist(X).isdir, 1:size(Flist)));
Flist(1:2) = []; 
Glist = [];
cpt = 1;
ind = 1;
while ind <= size(Flist,1)
    Tlist = dir([Flist(ind).folder filesep Flist(ind).name]);
    if( ~isempty( Tlist ) )
        Tlist(1:2) = [];
        Tlist = Tlist(arrayfun(@(X) Tlist(X).isdir, 1:size(Tlist)));
        for ind2 = 1:size(Tlist,1)
            if( contains( Tlist(ind2).name, {'Normoxia', 'Hypox'}) && ~endsWith(Tlist(ind2).name, 'OLD') ) % if( strcmp(Tlist(ind2).name, 'Figs_Results') )
                Glist(cpt).name = [Tlist(ind2).folder filesep Tlist(ind2).name];
                cpt = cpt + 1;
            else
                Flist = cat(1, Flist, Tlist(ind2));
            end
        end
    end
    ind = ind + 1;
    
end

%%
idx = arrayfun(@(x) contains(Glist(x).name, 'Normoxia_1'), 1:56);
Nlist = Glist(idx);
for ind = 5:7
    HypoxPipeline(Nlist(ind).name);
end

% run and make mask and roi
for ind = 1:size(Glist,2)
    HypoxPipeline(Glist(ind).name, 1);
end

for ind = 1:size(Glist,2)
    spO2Calculation(Glist(ind).name, 0);
end



Parameters = zeros(3,3,32);
for ind = 1:size(Glist,2)
    File = dir([Glist(ind).name filesep 'Params*.mat']);
    load([File.folder filesep File.name]);
    Parameters(:,:,ind) = Params;
end