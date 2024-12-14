%PASSIGN - assign variables with the value of each field in the calller

function passign(struct)
f = fieldnames(struct);
for jj = 1:length(f)
    assignin('caller', f{jj}, getfield(struct,f{jj}));
end
