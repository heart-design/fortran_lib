#include "fortran_lib.h"
program main
   USE_FORTRAN_LIB_H
   use, intrinsic:: iso_fortran_env, only: INPUT_UNIT, OUTPUT_UNIT, ERROR_UNIT
   use, intrinsic:: iso_fortran_env, only: REAL64
   use, non_intrinsic:: comparable_lib, only: almost_equal
   use, non_intrinsic:: optimize_lib, only: nnls
   use, non_intrinsic:: optimize_lib, only: init, update, Linesearchstate0RealDim0KindREAL64, Linesearchstate1RealDim0KindREAL64

   implicit none

  TEST(all(almost_equal(nnls(real(reshape([73, 87, 72, 80, 71, 74, 2, 89, 52, 46, 7, 71], shape=[4, 3]), kind=REAL64), real([49, 67, 68, 20], kind=REAL64)), [0.6495384364022547_REAL64, 0.0_REAL64, 0.0_REAL64])))
   TEST(all(almost_equal(nnls(real(reshape([1, 1, 0, 1], shape=[2, 2]), kind=REAL64), real([1, 0], kind=REAL64)), [1.0/2, 0.0])))

  TEST(test_line_search0(-3d0, 2d0, 1d1))
  TEST(test_line_search0(5d1, 15d-2, 1d1))
  TEST(test_line_search1(-3d0, 2d0, 1d1))
  TEST(test_line_search1(5d1, 15d-2, 1d1))

   write(OUTPUT_UNIT, *) 'SUCCESS: ', __FILE__

   stop

contains

   function test_line_search0(x0, dx, x_theoretical) result(ret)
      Logical:: ret
      Real(kind=real64), intent(in):: x0, dx, x_theoretical
      Real(kind=kind(x0)):: f, x, xl, xr, x_best, f_best, xtol
      Logical:: converge_x
      type(LineSearchState0RealDim0KindREAL64):: s

      ret = .true.
      xtol = 1e-2*dx
      f_best = huge(f_best)
      x_best = huge(x_best)
      call init(s)
      do
         x = x0 + s%x*dx
         f = f1(x, x_theoretical)
         if(s%iter > 2)then
            xl = x0 + s%xl*dx
            xr = x0 + s%xr*dx
            ! write(output_unit, *) xl, xr, x, f1(xl, x_theoretical), f1(xr, x_theoretical), f
         end if
         call update(s, f)
         converge_x = almost_equal(x, x_best, absolute=xtol)
         if(f < f_best)then
            x_best = x
            f_best = f
         end if
         if(converge_x) exit
      end do
      PRINT_VARIABLE(s%iter)
      PRINT_VARIABLE(x_best)
      ret = ret .and. almost_equal(x_theoretical, x_best, 10*xtol)

      f_best = huge(f_best)
      x_best = huge(x_best)
      call init(s)
      do
         x = x0 + s%x*dx
         f = f2(x, x_theoretical)
         if(s%iter > 2)then
            xl = x0 + s%xl*dx
            xr = x0 + s%xr*dx
            ! write(output_unit, *) xl, xr, x, f2(xl, x_theoretical), f2(xr, x_theoretical), f
         end if
         call update(s, f)
         converge_x = almost_equal(x, x_best, absolute=xtol)
         if(f < f_best)then
            x_best = x
            f_best = f
         end if
         if(converge_x) exit
      end do
      PRINT_VARIABLE(s%iter)
      PRINT_VARIABLE(x_best)
      ret = ret .and. almost_equal(x_theoretical, x_best, 10*xtol)
   end function test_line_search0

   function test_line_search1(x0, dx, x_theoretical) result(ret)
      Logical:: ret
      Real(kind=real64), intent(in):: x0, dx, x_theoretical
      Real(kind=kind(x0)):: f, g, x, x_best, f_best, g_best, xtol
      Logical:: converge
      type(LineSearchState1RealDim0KindREAL64):: s

      ret = .true.
      xtol = 1e-2*dx
      f_best = huge(f_best)
      x_best = huge(x_best)
      call init(s)
      do
         x = x0 + s%x*dx
         f = f1(x, x_theoretical)
         g = g1(x, x_theoretical)
         ! if(s%iter > 1)then
         !    write(output_unit, *) x_best, f_best, g_best, x, f, g, s%is_convex
         ! end if
         call update(s, f, g, dx)
         converge = abs(g) < 1e-6 .or. almost_equal(x, x_best, absolute=xtol)
         if(f < f_best)then
            x_best = x
            f_best = f
            g_best = g
         end if
         if(s%iter > 50) stop
         if(converge) exit
      end do
      PRINT_VARIABLE(s%iter)
      PRINT_VARIABLE(x_best)
      ret = ret .and. almost_equal(x_theoretical, x_best, 10*xtol)

      f_best = huge(f_best)
      x_best = huge(x_best)
      call init(s)
      do
         x = x0 + s%x*dx
         f = f2(x, x_theoretical)
         g = g2(x, x_theoretical)
         ! if(s%iter > 1)then
         !    write(output_unit, *) x_best, f_best, g_best, x, f, g, s%is_convex
         ! end if
         call update(s, f, g, dx)
         converge = abs(g) < 1e-6 .or. almost_equal(x, x_best, absolute=xtol)
         if(f < f_best)then
            x_best = x
            f_best = f
            g_best = g
         end if
         if(converge) exit
      end do
      PRINT_VARIABLE(s%iter)
      PRINT_VARIABLE(x_best)
      ret = ret .and. almost_equal(x_theoretical, x_best, 10*xtol)
   end function test_line_search1

   function f1(x, x_theoretical) result(y)
      Real(kind=real64), intent(in):: x, x_theoretical
      Real(kind=kind(x)):: y
      Real(kind=kind(x)):: x_

      x_ = x - x_theoretical
      y = -1/(1 + x_**2)
   end function f1

   function f2(x, x_theoretical) result(y)
      Real(kind=real64), intent(in):: x, x_theoretical
      Real(kind=kind(x)):: y
      Real(kind=kind(x)):: x_

      x_ = x - x_theoretical
      y = x_**2 - cos(x_)
   end function f2

   function g1(x, x_theoretical) result(y)
      Real(kind=real64), intent(in):: x, x_theoretical
      Real(kind=kind(x)):: y
      Real(kind=kind(x)):: x_

      x_ = x - x_theoretical
      y = 2*x_/(1 + x_**2)**2
   end function g1

   function g2(x, x_theoretical) result(y)
      Real(kind=real64), intent(in):: x, x_theoretical
      Real(kind=kind(x)):: y
      Real(kind=kind(x)):: x_

      x_ = x - x_theoretical
      y = 2*x_ + sin(x_)
   end function g2
end program main
