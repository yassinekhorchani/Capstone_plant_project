import h5py
import numpy as np

f = h5py.File('my_model(1).h5', 'r')
print('Dense layer shapes:')
try:
    d = f['model_weights/dense/dense/kernel:0'][()]
    print(f'dense kernel: {d.shape}')
except:
    print('dense: not found')

try:
    d1 = f['model_weights/dense_1/dense_1/kernel:0'][()]
    print(f'dense_1 kernel: {d1.shape}')
except:
    print('dense_1: not found')
    
try:
    d2 = f['model_weights/dense_2/dense_2/kernel:0'][()]
    print(f'dense_2 kernel: {d2.shape}')
    print(f'This is the final layer with {d2.shape[1]} classes')
except:
    print('dense_2: not found')

f.close()
