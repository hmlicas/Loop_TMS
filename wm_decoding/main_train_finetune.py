import tensorflow as tf

from data_loader.data_generator import DataGenerator
from models.task_pred_model import TaskPredModel
from trainers.task_pred_trainer import TaskPredTrainer
from utils.config import process_config_finetune
from utils.dirs import create_dirs
from utils.logger import Logger
from utils.utils import get_args


def main():
	# capture the config path from the run arguments
	# then process the json configration file
	try:
		args = get_args()
		config = process_config_finetune(args.config)

	except:
		print("missing or invalid arguments")
		exit(0)

	# create the experiments dirs
	create_dirs([config.summary_dir, config.checkpoint_dir])

	# create tensorflow session
	sess = tf.Session()
	# create instance of the model you want
	model = TaskPredModel(config)
	# load pretrained model
	model.load_pretrain(sess)

	# create your data generator
	data = DataGenerator(config.train_data)
	data_val = DataGenerator(config.validation_data)

	# create tensorboard logger
	logger = Logger(sess, config)

	# create trainer and path all previous components to it
	trainer = TaskPredTrainer(sess, model, data, data_val, config, logger)

	# here you train your model
	trainer.train()

	# save trained model
	model.save(sess)


if __name__ == '__main__':
    main()
