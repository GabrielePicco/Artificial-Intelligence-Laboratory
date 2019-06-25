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

observation_sigma = 0.9  # observation (measurements) noise
transition_sigma = 0.9  # transition noise
initial_state_noise = 10
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
        print("kalman gain: {}".format(elem[0]))


# specify parameters
transition_matrix = [[0.9, 0.1], [0, 1]]  # [[posizione_x, posizione_y],[velocita_x, velocita_y]]
observation_matrix = np.eye(2)
transition_covariance = np.eye(2) * np.random.normal(gaussian_mean, transition_sigma)
observation_covariance = np.eye(2) * np.random.normal(gaussian_mean, observation_sigma)
initial_state_mean = [5, -5]
# sample from model
kf = KalmanFilter(
    transition_matrix, observation_matrix, transition_covariance,
    observation_covariance, initial_state_mean = initial_state_mean
)
states, observations = kf.sample(
    n_timesteps=26,
    initial_state=np.random.normal(gaussian_mean, initial_state_noise))

# perfect start from X0
# states, observations = kf.sample(
#     n_timesteps=26,
#     initial_state=initial_state_mean)

# estimate state with filtering
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
