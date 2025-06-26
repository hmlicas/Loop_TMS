from base.base_train import BaseTrain
from tqdm import tqdm
import numpy as np

class TaskPredTrainer(BaseTrain):
    def __init__(self, sess, model, data, data_val, config, logger):
        super(TaskPredTrainer, self).__init__(sess, model, data, data_val, config, logger)

    def train_epoch(self):
        loop = tqdm(range(self.config.num_iter_per_epoch))
        losses = []
        for it in loop:
            loss = self.train_step()
            losses.append(loss)
        
        loss = np.mean(losses)

        losses_val = []
        for it in range(10):
            loss_val = self.validation_step()
            losses_val.append(loss_val)                

        loss_val = np.mean(losses_val)

        cur_it = self.model.global_step_tensor.eval(self.sess)
        summaries_dict = {}
        summaries_dict['loss'] = loss
        summaries_dict['loss_val'] = loss_val
        self.logger.summarize(cur_it, summaries_dict=summaries_dict)

    def train_step(self):
        batch_x, batch_y, seq_len = next(self.data.next_batch(self.config.batch_size))
        
        feed_dict = {self.model.x: batch_x, self.model.y: batch_y, self.model.seq_len: seq_len}
        _, loss = self.sess.run([self.model.train_step, self.model.loss],
                                feed_dict=feed_dict)
        return loss

    def validation_step(self):
        batch_x, batch_y, seq_len = next(self.data_val.next_batch(self.config.batch_size))
        
        feed_dict = {self.model.x: batch_x, self.model.y: batch_y, self.model.seq_len: seq_len}
        loss = self.sess.run(self.model.loss, feed_dict=feed_dict)

        return loss