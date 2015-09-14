my_data_set = params_tests_fileset('*.mat', 1/32000, 1, 'gr79pu85_1_20_15', struct('fileParamsRegexp', '(?<name>onset)-(?<val>[\d\.]+)', 'loadItemProfileFunc', @birdsong_db_profile));
my_db = params_tests_db(my_data_set); % This step could take a while
