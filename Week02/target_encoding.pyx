# distutils: language=c++
cimport numpy as np
import numpy as np
from libcpp.map cimport map
from libcpp.vector cimport vector
from cython.operator cimport dereference as deref

cdef extern from "target_encoding.h":
    vector[long] target_encoding(double *, const long, const long)

FTYPE = np.float

cpdef target_mean_v3(np.ndarray[long, ndim=2] data, int y_name, int x_name):
    cdef int size = data.shape[0]
    ret = np.zeros(size, dtype = FTYPE)
    cdef map[long, long] value_dict
    cdef map[long, int] count_dict
    cdef map[long, long].iterator it
    cdef long x_val

    for i in range(size):
        x_val = data[i, x_name]
        it = value_dict.find(x_val);
        if it == value_dict.end():
            value_dict[x_val] = data[i, y_name]
            count_dict[x_val] = 1
        else:
            value_dict[x_val] += data[i, y_name]
            count_dict[x_val] += 1

    for i in range(size):
        x_val = data[i, x_name]
        ret[i] = (value_dict[x_val] - data[i, y_name]) / (count_dict[x_val] - 1)
    return ret

@cython.boundscheck(False)
@cython.wraparound(False)
cpdef float[:] target_mean_v4(long[:, :] data, int y_name, int x_name, int x_range):
    cdef int size = data.shape[0]
    cdef float[:] ret = np.zeros(size, dtype = float)
    cdef vector[long] *values = new vector[long](x_range, 0)
    cdef vector[long] *counts = new vector[long](x_range, 0)
    cdef long x_val

    for i in range(size):
        x_val = data[i, x_name]
        values[x_val] += data[i, y_name]
        counts[x_val] += 1

    for i in range(size):
        x_val = data[i, x_name]
        ret[i] = (deref(values)[x_val] - data[i, y_name]) / (deref(counts)[x_val] - 1)

    del values
    del counts
    return ret

def target_mean_v5(data, y_name, x_name):
    matrix = data[[y_name, x_name]].values
    cdef np.ndarray[long, ndim = 2, mode = 'c'] arg = np.ascontiguousarray(matrix, dtype = np.long)

    ret = list(target_encoding(&arg[0, 0], matrix.shape[0], matrix.shape[1]))
    return ret
