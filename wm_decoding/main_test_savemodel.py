import tensorflow as tf
import numpy as np
import scipy.io as sio
import os
import time

from models.task_pred_model import TaskPredModel
from utils.config import process_config
from utils.dirs import create_dirs
#from utils.logger import Logger
from utils.utils import get_args


def main():
    # capture the config path from the run arguments
    # then process the json configration file
    try:
        args = get_args()
        config = process_config(args.config)

    except:
        print("missing or invalid arguments")
        exit(0)

    # create the experiments dirs
    create_dirs([config.test_output_dir])

    # create tensorflow session
    sess = tf.Session()

    # create instance of the model you want
    model = TaskPredModel(config)
    # load model
    model.load(sess)

    # get test data
    #mat_input = sio.loadmat(config.test_data)
    mat_input = sio.loadmat(config.validation_data)

    x = mat_input["t_x"]
    seq_len = mat_input["t_len"].flatten()
    #y = mat_input["t_y"]
    #y_mask = mat_input["t_mask"]

    N_test = 5 #x.shape[0]

    output = []
    batch_size = config.batch_size
    num_iter = 5 #np.int32(np.ceil(N_test/batch_size))

    s_time = time.time();
    for bi in range(num_iter):
        if bi < num_iter-1:
            run_ind = range(bi*batch_size, (bi+1)*batch_size)
        else:
            run_ind = list(range(bi*batch_size, N_test)) + list(range(num_iter*batch_size-N_test))
        
        r_sequences = x[run_ind,:,:]
        r_seq_len = seq_len[run_ind]
        bi_output = sess.run([model.y_], {model.x: r_sequences, model.seq_len: r_seq_len})
        
        bi_y_ = bi_output[0]
        if bi == num_iter-1:
            bi_y_ = bi_output[0][0:N_test-(num_iter-1)*batch_size,:,:]
                
        output.append(bi_y_)

    output = np.concatenate(output, axis=0)

    e_time = time.time()
    print("Testing takes {:.2f} seconds.".format(e_time-s_time))

    tf.saved_model.simple_save(sess, config.saved_model_dir,
                               inputs={"input":model.x, "seq_len":model.seq_len},
                               outputs={"readout":model.y_})


if __name__ == '__main__':
    tf.compat.v1.logging.set_verbosity(tf.compat.v1.logging.ERROR)
    main()
