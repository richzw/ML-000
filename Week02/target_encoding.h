#pragma once
#include <vector>
#include <cmath>
#include <iostream>

template<typename T, bool col_major=false>
class MatrixView{
public:
    T* data_pointer;
    const long nrow;
    const long ncol;

    MatrixView(T *data_pointer, const long nrow, const long ncol) :
        data_pointer(data_pointer),
        nrow(nrow),
        ncol(ncol) {}

    T &operator()(const int row, const int col) {
        if (col_major) {
            return data_pointer[row + col * nrow];
        } else {
            return data_pointer[col + row * ncol];
        }
    }

    T operator()(const int row, const int col) const {
        if (col_major) {
            return data_pointer[row + col * nrow];
        } else {
            return data_pointer[col + row * ncol];
        }
    }
};


std::vector<double> target_encoding(double *data, const long nrow, const long ncol) {
    const MatrixView<long, true> data_view(data, nrow, ncol);
    long* values = new long[nrow]();
    long* counts = new long[nrow]();
    long x_val;
    std::vector<double> ret;
    ret.resize(nrow);

    for (auto i = 0; i < nrow; i++) {
        x_val = data_view(i, 0);
        values[x_val] += data_view(i, 1);
        counts[x_val] += 1;
    }

    for (auto i = 0; i < nrow; i++) {
        x_val = data_view(i, 0);
        ret[i] = (values[x_val] - data_view(i, 1)) / (counts[x_val] - 1)
    }

    delete[] values;
    delete[] counts;
}


