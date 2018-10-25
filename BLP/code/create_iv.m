function Dataset = create_iv(Dataset, params)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
IV_type = params.IV_type;
firm_dummy = dummyvar(Dataset.data.firm);
prod_char = [Dataset.data.weight Dataset.data.hp Dataset.data.AC];

switch IV_type
    case 'BLP'
        for i = 1:params.nb_cars
            sum_within(i,:) = sum(prod_char(Dataset.data.firm==Dataset.data.firm(i),:),1);
            sum_outside(i,:) = sum(prod_char(Dataset.data.firm~=Dataset.data.firm(i),:),1);
        end
        sum_within = sum_within-prod_char;
        Dataset.IV = [ones(params.nb_cars,1) prod_char  firm_dummy(:,2:end) sum_within];
    case 'Houde'
        for i = 1:params.nb_cars
            sum_abs(i,:) = sum(abs(prod_char-prod_char(i,:)),1);
            sum_square(i,:) = sum((prod_char-prod_char(i,:)).^2,1);
        end
        Dataset.IV = [ones(params.nb_cars,1) prod_char  firm_dummy(:,2:end) sum_abs];
    otherwise
        warning('No IV type specified');
end

Dataset.W = inv(Dataset.IV'*Dataset.IV);
Dataset.Pz =  Dataset.IV* Dataset.W * Dataset.IV';
end

