'''
===========================================
Kalman Filter Experiments
===========================================
Kalman Filter using 2 variables (position, velocity)
Plotting only position states (true, filtered, observed


'''
import numpy as np
import pylab as pl
from pykalman import KalmanFilter

observation_sigma = 0.5  # observation (measurements) noise
transition_sigma = 0.5  # transition noise
gaussian_mean = 5


def get_position_states(matrix):
    """
    method to get the position column of a matrix (position, velocity)
    as list, in order to get only the position elements
    :param matrix: matrix to transform
    :return: list of element representing position coordinates
    """
    position_col = []
    for elem in matrix:
        position_col.append(elem[0])
    return position_col

def print_formatted_info(kalman_gain):
    for elem in kalman_gain:
        print("kalman gain: {}".format(elem))


# specify parameters
transition_matrix = [[1, 0.1], [0, 1]]  # [[posizione_x, posizione_y],[velocita_x, velocita_y]]
observation_matrix = np.eye(2)
transition_covariance = np.eye(2) * np.random.normal(gaussian_mean, transition_sigma)
observation_covariance = np.eye(2) * np.random.normal(gaussian_mean, observation_sigma)

# sample from model
kf = KalmanFilter(
    transition_matrix, observation_matrix, transition_covariance,
    observation_covariance
)
states, observations = kf.sample(
    n_timesteps=26,
    initial_state=np.random.normal(2, 0.1))
# estimate state with filtering and smoothing

filtered_state_estimates, predicted_state_covariance, kalman_gain = kf.filter(observations)

# draw estimates
pl.figure()
lines_true = pl.plot(get_position_states(states), color='b')
lines_filt = pl.plot(get_position_states(filtered_state_estimates), color='r')
scat_observ = pl.plot(get_position_states(observations), 'gx')
# lines_smooth = pl.plot(smoothed_state_estimates, color='g')
pl.legend((lines_true[0], lines_filt[0], scat_observ[0]),
          ('true', 'filt', 'observ'),
          loc='lower right'
          )
pl.show()

print_formatted_info(kalman_gain)