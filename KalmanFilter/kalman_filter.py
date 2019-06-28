'''
===========================================
Kalman Filter Experiments
===========================================
Kalman Filter using 2 variables (position, velocity)
'''
import numpy as np
import pylab as pl
from pykalman import KalmanFilter
import scipy.stats as stats
import math

PERFECT_START = True


def get_states_and_observations(kf, time_steps, initial_state_mean):
    '''
    Sample a sequence of state and observations in timesteps legnth
    :param kf: initialized kalman filter
    :param time_steps: number of iterations
    :param initial_state_mean:  mean of the initial state
    :return: sampled states and observations
    '''
    states, observations = states, observations = kf.sample(
        n_timesteps=time_steps,
        initial_state=initial_state_mean)
    return states, observations


def generate_exp_states_and_obs():
    '''
    Generate a sequence of 10 exponential distributed numbers. Limited
    to 10 timesteps to avoid function explosion
    :return: sequence of exponential sampled states and observation
    '''
    states = []
    observations = []
    for i in range(10):
        states.append([math.exp(i), i])
    for e in states:
        x = (np.dot(np.eye(2), e) + observation_offsets + np.random.normal(1, 0.5))
        observations.append(x)
    return states, observations


def draw_estimates(states, filtered_state_estimates, observations):
    pl.figure()
    lines_true = pl.plot(get_position_states(states), 'b-s')
    lines_filt = pl.plot(get_position_states(filtered_state_estimates), 'r--x')
    scat_observ = pl.plot(get_position_states(observations), 'g*')
    pl.legend((lines_true[0], lines_filt[0], scat_observ[0]),
              ('true', 'filtered', 'observed'),
              loc='upper left'
              )
    pl.xlabel('timesteps')
    pl.ylabel('position')
    pl.show()


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


def print_parameters(observation_sigma, transition_sigma, initial_state_mean, initial_state_sigma):
    print("Observations Gaussian Noise (Sigma_z): {}".format(observation_sigma))
    print("Transition Gaussian Noise (Sigma_x): {}".format(transition_sigma))
    print("Initial State: {} perfect start no noise".format(
        initial_state_mean) if PERFECT_START else "Initial State: {} with noise sigma: {}".format(initial_state_mean,
                                                                                                  initial_state_sigma))


def print_estimated_errors(PERFECT_START, states, filtered_state_estimates):
    estimated_errors = []
    for i, (rs, es) in enumerate(zip(states, filtered_state_estimates)):
        estimated_errors.append(abs(rs[0] - es[0]))
        print("Estimated error at time step {} is {}".format(i, abs(rs[0] - es[0])))
    print("Mean error is {}".format(np.mean(estimated_errors)))


# parameters initialization
observation_sigma = 0.1
transition_sigma = 0.9
initial_state_sigma = 0.1
gaussian_mean_obs, gaussian_mean_transit, gaussian_mean_init_s = 2, 2, 2
time_steps = 10
transition_matrix = [[0.5, 0.1], [0.5, 0.9]]  # [[position_x, position_y],[velocity_x, velocity_y]]
observation_matrix = np.eye(2)
transition_covariance = np.eye(2) * np.random.normal(gaussian_mean_transit, transition_sigma)
observation_covariance = np.eye(2) * np.random.normal(gaussian_mean_obs, observation_sigma)
initial_state_mean = [1, 1]
transition_offsets = [1, 1]
observation_offsets = [0, 0]
if PERFECT_START:
    initial_state_covariance = np.eye(2)
else:
    initial_state_covariance = np.eye(2) * np.random.normal(gaussian_mean_init_s, initial_state_sigma)  # P0

# filter initialization
kf = KalmanFilter(
    transition_matrix, observation_matrix, transition_covariance,
    observation_covariance, transition_offsets=transition_offsets, observation_offsets=observation_offsets,
    initial_state_mean=initial_state_mean, initial_state_covariance=initial_state_covariance
)

# get transition model, observations and apply filter
states, observations = get_states_and_observations(kf, time_steps, initial_state_mean)  # linear sample
# states, observations = generate_exp_states_and_obs() # non linear (exponential) sample
filtered_state_estimates, predicted_state_covariance, kalman_gains = kf.filter(observations)

# draw estimates and print parameters and results
print_parameters(observation_sigma, transition_sigma, initial_state_mean, initial_state_sigma)
draw_estimates(states, filtered_state_estimates, observations)
print_estimated_errors(PERFECT_START, states, filtered_state_estimates)
print("Kalman gains trough timesteps \n{}".format(kalman_gains))
