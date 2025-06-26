
Requirements:
	tensorflow (version <=1.15)
	numpy
	scipy
	tqdm
	bunch


Usage:
1. Model training:
	python main_train.py -c example_config.json

	A example config file can be found here: ./configs/task_pred_config_2back_rs3_training.json

2. Model testing:
	python main_test.py -c example_config.json

	The prediction results will be saved as 'output_prediction.mat' in the 'test_output_dir' as set in the config.json file

3. Model configuration file (.json):
	{
	  "exp_name": "task_pred_tms_baseline_2back",		# name for the experiment/model
	  "train_data": "/data/hmli_comp/tms_decoding/data/tc_data_task_pred_tf_2back_rs3/nback02_run-01_train_v2.mat",		# location for the training data
	  "is_training": "True",							# Training (True) or testing (False) the model?
	  "model_output": "/data/hmli_comp/tms_decoding/results/tms_baseline_2back_model_rs3_v2",							# where the trained model will be saved
	  "test_data": "/data/hmli_comp/tms_decoding/data/tc_data_task_pred_tf_2back_rs3/nback02_run-01_test_v2.mat",		# location for the testing data
	  "test_output_dir": "/data/hmli_comp/tms_decoding/results/tms_baseline_2back_test_rs3_v2",							# where the testing results will be saved
	  "num_epochs": 20,	
	  "num_iter_per_epoch": 5000,
	  "learning_rate": 0.001,
	  "decay_steps": 20000,
	  "decay_rate": 0.1,
	  "batch_size": 32,
	  "step_num": 25,								# number of time points of the fMRI data used for training and testing
	  "fea_num": 49,								# number of brain ROIs/functional networks
	  "num_hidden_layers": 2,						# number of hidden layers in the LSTM RNNs
	  "hidden_num": 128,							# number of hidden nodes in each LSTM layer
	  "output_num": 2,								# number of brain states to be decoded
	  "dropout_keep_rate": 0.8,
	  "max_to_keep": 10
	}

4. Prepare the training/testing data:
	Currently the training and testing data files are saved in .mat format (Matlab file).
	The data file contains:
		t_x: 3D tensor with size [num_sample, win_size, num_roi], the input time courses for decoding (win_size: number of time points in the fMRI segment; num_roi: number of brain regions/functional networks).
		t_y: 3D tensor with size [num_sample, win_size, num_state], the labels of brain states to be decoded.
		t_len: array with size [num_sample, 1], containing the win_size of each fMRI segment used for decoding.
