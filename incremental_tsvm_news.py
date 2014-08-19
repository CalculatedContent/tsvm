# coding: utf-8

import pandas as pd
import numpy as np

import scipy
import scipy.sparse

import sklearn
import sklearn.svm
import sklearn.datasets
import sklearn.cross_validation

import warnings
warnings.filterwarnings('ignore')


X, y = sklearn.datasets.load_svmlight_file('data/news20.binary')

instance_ids = np.arange(y.size)

splits = sklearn.cross_validation.StratifiedShuffleSplit(y, n_iter=1, test_size=0.95)
labeled_indices, unlabeled_indices = splits.__iter__().next()

L = X[labeled_indices]
L_ids = instance_ids[labeled_indices]

U = X[unlabeled_indices]
U_ids = instance_ids[unlabeled_indices]

y_l = y[labeled_indices]
y_u = y[unlabeled_indices]


def increment_svm(svm, L_ids, baseline_accuracy):
    
    L = X[L_ids]
    y_l = y[L_ids]
    
    U_ids = np.array(list((set(instance_ids) - set(L_ids))))
    U = X[U_ids]
    y_u = y[U_ids]

    ordered_indices = np.argsort(svm.decision_function(U))
    smallest_indices = ordered_indices[:500]
    smallest_ids = U_ids[smallest_indices]
    largest_indices = ordered_indices[-500:]
    largest_ids = U_ids[largest_indices]
    
    high_confidence_unlabeled = scipy.sparse.vstack([U[smallest_indices], U[largest_indices]])
    high_confidence_ids = np.concatenate([smallest_ids, largest_ids])
    high_confidence_predicted_labels = svm.predict(high_confidence_unlabeled)
    high_confidence_true_labels = y[high_confidence_ids]
    
    splits = sklearn.cross_validation.StratifiedShuffleSplit(high_confidence_predicted_labels, n_iter=2, test_size=0.9)

    saved_L_primes = []
    saved_L_prime_ids = []
    saved_cv_accuracies = []

    for augment_indices, test_indices in splits:

        augment = high_confidence_unlabeled[augment_indices]
        test = high_confidence_unlabeled[test_indices]

        augment_ids = high_confidence_ids[augment_indices]
        test_ids = high_confidence_ids[test_indices]

        augment_labels = high_confidence_predicted_labels[augment_indices] 
        test_labels = high_confidence_predicted_labels[test_indices]

        L_prime = scipy.sparse.vstack([L, augment])

        y_l_prime = np.concatenate([y_l, augment_labels])
        L_prime_ids = np.concatenate([L_ids, augment_ids])

        saved_L_primes.append(L_prime)
        saved_L_prime_ids.append(L_prime_ids)    

        svm_prime = sklearn.svm.LinearSVC(penalty='l2', C=10, dual=False)
        accuracy = sklearn.cross_validation.cross_val_score(svm_prime, L_prime, y_l_prime, cv=5, n_jobs=7).mean()

        saved_cv_accuracies.append(accuracy)
            
    best_index = np.argmax(saved_cv_accuracies)
    best_L_prime_ids = saved_L_prime_ids[best_index]
    best_accuracy = saved_cv_accuracies[best_index]
    
    return best_L_prime_ids, best_accuracy


svm = sklearn.svm.LinearSVC(penalty='l2', C=10, dual=False)
svm.fit(L, y_l)
cv_accuracy = sklearn.cross_validation.cross_val_score(svm, L, y_l, cv=5, n_jobs=7).mean()

accuracies = [cv_accuracy]

iteration = 0
number_labeled = L.shape[0]
prediction_accuracy = sklearn.metrics.accuracy_score(y_u, svm.predict(U))

print "%d\t%d\t%f\t%f" %(iteration, number_labeled, cv_accuracy, prediction_accuracy)


while True:
    iteration += 1

    L_ids, cv_accuracy = increment_svm(svm, L_ids, cv_accuracy)
    
    L = X[L_ids]
    y_l = y[L_ids]
    
    U_ids = np.array(list((set(instance_ids) - set(L_ids))))
    U = X[U_ids]
    y_u = y[U_ids]
    
    svm = sklearn.svm.LinearSVC(penalty='l2', C=10, dual=False)
    svm.fit(L, y_l)
    
    number_labeled = L.shape[0]
    
    prediction_accuracy = sklearn.metrics.accuracy_score(y_u, svm.predict(U))
    print "%d\t%d\t%f\t%f" %(iteration, number_labeled, cv_accuracy, prediction_accuracy)
