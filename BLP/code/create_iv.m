function Dataset = create_iv(Dataset, params)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
IV_type = params.IV_type;
firm = Dataset.data.firm;
prod_char = [Dataset.data.weight Dataset.data.hp Dataset.data.AC];
X = Dataset.X;

switch IV_type
    case 'BLP'
        for i = 1:params.nb_cars
            sum_within(i,:) = sum(prod_char(firm==firm(i),:),1);
            sum_outside(i,:) = sum(prod_char(firm~=firm(i),:),1);
        end
        sum_within = sum_within-prod_char;
        Dataset.IV = [X sum_within sum_outside];
    case 'Houde'
        for i = 1:params.nb_cars
            sum_abs(i,:) = sum(abs(prod_char-prod_char(i,:)),1);
            sum_square(i,:) = sum((prod_char-prod_char(i,:)).^2,1);
        end
        Dataset.IV = [X sum_square];
    otherwise
        warning('No IV type specified');
end

Dataset.W = (Dataset.IV'*Dataset.IV)\eye(size(Dataset.IV,2));
Dataset.Pz =  Dataset.IV* Dataset.W * Dataset.IV';
end

