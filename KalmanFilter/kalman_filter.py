'''
===========================================
Kalman Filter Experiments
===========================================
- Kalman Filter using 2 variables (position, velocity)
- Plotting only position states (true, filtered, observed
- 4 variables, print only position measures (filt, obs, true)
- Samples function: parte da uno stato iniziale e itera "n_timestamps" volte
generando gli stati reali (states) e le osservazioni (observations9
- Il filtro è inizializzato con la matrice di transizione (serve a calcolare lo stato corrente
a partire da quello precedente con rumore), matrice di osservazione (misure dei sensori con
rumore), le matrici di covarianza sia di transizione che di osservazione (indicano la quantità
di rumore, matrici di 1 (np.eye) moltiplicate per rumore gaussiano)
- Transition offset: corrisponde a "b" nell'aggiornamento della gaussiana del processo: Ax + b
- Observation offset: corrisponde a "b" nell'aggiornamento della gaussiana delle osservazioni: Ax + b

- Test da fare:
Rumore osservazioni: nullo, alto, basso
Rumore transizioni: nullo, alto, basso
Provare varie combinazioni: es. errore di processo nullo e di osservazione molto alto, tutti e due nulli, ecc...
Stato iniziale: Rumore nullo, alto, basso

(facoltativo) simulare un processo (più o meno) non lineare e
vedere come si comporta il KF
'''
import numpy as np
import pylab as pl
from pykalman import KalmanFilter
import scipy.stats as stats
import math

PERFECT_START = True


def initialize_kalman_filter(observation_sigma, transition_sigma, initial_state_sigma):
    gaussian_mean_obs, gaussian_mean_transit, gaussian_mean_init_s = 1, 1, 1
    time_steps = 10
    transition_matrix = [[0.5, 0.1], [0.5, 0.9]]  # [[posizione_x, posizione_y],[velocita_x, velocita_y]]
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
    kf = KalmanFilter(
        transition_matrix, observation_matrix, transition_covariance,
        observation_covariance, transition_offsets=transition_offsets, observation_offsets=observation_offsets,
        initial_state_mean=initial_state_mean, initial_state_covariance=initial_state_covariance
    )
    print_parameters(observation_sigma, transition_sigma, initial_state_mean, initial_state_sigma)
    return kf, get_states_and_observations(kf, time_steps, initial_state_mean)


def get_states_and_observations(kf, time_steps, initial_state_mean):
    states, observations = states, observations = kf.sample(  # linear sample
        n_timesteps=time_steps,
        initial_state=initial_state_mean)
    return states, observations


def generate_exp_states_and_obs():
    states = []
    observations = []
    for i in range(10):
        states.append([math.exp(i), i])
    for e in states:
        x = (np.dot(np.eye(2), e) + observation_offsets + np.random.RandomState(2).multivariate_normal(np.zeros(2),
                                                                                                       observation_covariance.newbyteorder(
                                                                                                           '=')))
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


kf, (states, observations) = initialize_kalman_filter(observation_sigma=0.1, transition_sigma=0.1,
                                                      initial_state_sigma=0.1)

# states, observations = generate_exp_states_and_obs() # non linear (exponential) sample

filtered_state_estimates, predicted_state_covariance, kalman_gains = kf.filter(observations)
draw_estimates(states, filtered_state_estimates, observations)
print_estimated_errors(PERFECT_START, states, filtered_state_estimates)
print("Kalman gains trough timesteps \n{}".format(kalman_gains))
