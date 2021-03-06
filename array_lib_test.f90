#include "fortran_lib.h"
program main
   USE_FORTRAN_LIB_H
   use, intrinsic:: iso_fortran_env, only: INPUT_UNIT, OUTPUT_UNIT, ERROR_UNIT
   use, intrinsic:: iso_fortran_env, only: INT64
   use, non_intrinsic:: comparable_lib, only: almost_equal
   use, non_intrinsic:: array_lib, only: iota, l2_norm, eye, get, mul_diag

   implicit none

   Integer:: i
   Integer:: nss(3, 4)
   Real:: A(3, 4), B(3, 4)

   A(1, :) = [1, 2, 3, 4]
   A(2, :) = [5, 6, 7, 8]
   A(3, :) = [9, 10, 11, 12]
   B(:, 1) = 1*A(:, 1)
   B(:, 2) = 2*A(:, 2)
   B(:, 3) = 3*A(:, 3)
   B(:, 4) = 4*A(:, 4)
   TEST(all(almost_equal(mul_diag(A, [1.0, 2.0, 3.0, 4.0]), B)))
   B(1, :) = 1*A(1, :)
   B(2, :) = 2*A(2, :)
   B(3, :) = 3*A(3, :)
   TEST(all(almost_equal(mul_diag([1.0, 2.0, 3.0], A), B)))

   TEST(almost_equal(l2_norm([1.0, 2.0]), 5.0))

   TEST(all(iota(0) == [(i, i = 1, 0)]))
   TEST(all(iota(1) == [1]))
   TEST(all(iota(2) == [1, 2]))
   TEST(all(iota(3) == [1, 2, 3]))

   TEST(all(iota(-3, -4) == [(i, i = 1, 0)]))
   TEST(all(iota(-3, -3) == [-3]))
   TEST(all(iota(-3, -2) == [-3, -2]))
   TEST(all(iota(-3, -1) == [-3, -2, -1]))

   TEST(all(iota(2, 3, -3) == [(i, i = 1, 0)]))
   TEST(all(iota(2, 2, -3) == [2]))
   TEST(all(iota(2, 1, -3) == [2]))
   TEST(all(iota(2, 0, -3) == [2]))
   TEST(all(iota(2, -1, -3) == [2, -1]))
   TEST(all(iota(2, -2, -3) == [2, -1]))
   TEST(all(iota(2, -3, -3) == [2, -1]))
   TEST(all(iota(2, -4, -3) == [2, -1, -4]))

   nss = eye(size(nss, 1), size(nss, 2))
   TEST(nss(1, 1) == 1)
   TEST(nss(1, 2) == 0)
   TEST(nss(1, 3) == 0)
   TEST(nss(1, 4) == 0)
   TEST(nss(2, 1) == 0)
   TEST(nss(2, 2) == 1)
   TEST(nss(2, 3) == 0)
   TEST(nss(2, 4) == 0)
   TEST(nss(3, 1) == 0)
   TEST(nss(3, 2) == 0)
   TEST(nss(3, 3) == 1)
   TEST(nss(3, 4) == 0)

   TEST(get(iota(5), 1) == 1)
   TEST(get(iota(5), 2_INT64) == 2)
   TEST(get(iota(5), 3) == 3)
   TEST(get(iota(5), 4) == 4)
   TEST(get(iota(5), 5) == 5)

   write(OUTPUT_UNIT, *) 'SUCCESS: ', __FILE__
   
   stop
end program main
