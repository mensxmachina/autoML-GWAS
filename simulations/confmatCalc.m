function [TP, FP] = confmatCalc(ref, alt, useQ, altQ)

Sref = 1:length(ref);
Salt = 1:length(alt);

[TP, intAlt, intRef] = intersect(alt, ref, 'stable');

[~, sdifRef] = setdiff(ref, alt, 'stable');
[~, sdifAlt] = setdiff(alt, ref, 'stable');

if useQ
    for r = sdifRef'
        
        if ~isempty(sdifAlt')
            for a = sdifAlt'
                q2check = altQ{a};

                if any(q2check == ref(r))
                    TP = [TP, ref(r)];
                    sdifAlt(sdifAlt==a) = [];                
                    break
                end
            end
        else
            break
        end
    end
end

FP = alt(sdifAlt);

end

