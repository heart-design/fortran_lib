#!/bin/bash

IFS=$' \t\n'

# set -xv
set -o nounset
set -o errexit
set -o pipefail
set -o noclobber

readonly program_name="${0##*/}"
usage_and_exit(){
   {
      cat <<EOF
This program makes input data for etas_solve.exe

Example:
$program_name [options] --t_normalize_len=1 --m_for_K=6 --t_pre=0 --t_begin=10 --t_end=60 --data_file=path/to/data_file | path/to/etas_solve.exe

--t_pre, --t_begin, --t_end:
t_pre <= t_begin <= t_end.
Earthquakes in [t_begin, t_end] are fitted by etas_solve.exe.
Earthquakes in [t_pre, t_begin) are not fitted although intensities from them to earthquakes in [t_begin, t_end] are considered.

--data_file:
The first column should be time, and the second column should be magnitude.
Time should be sorted in ascending order.

--m_for_K:
Reference magnitude.

--t_normalize_len:
Normalization time interval.
Background intensity produces mu earthquakes per t_normalize_len on average.
A M == m_for_K earthquake produces K direct aftershocks per t_normalize_len, on average.

[options]:

--c[=0.01], --p[=1.1], --alpha[=0.5], --K[=1], --mu[=1]:
Initial values.
Using a good initial value may reduce number of iterations needed to converge.
Initial value should satisfy lower <= initial value <= upper.

--lower[=1d-8,-1,-1,0,1d-8]:
Lower bounds of the ETAS parameters.
Order is c,p,alpha,K,mu.

--upper[=3,4,5,1d308,1d308]:
Upper bounds of the ETAS parameters.
Order is c,p,alpha,K,mu.
Setting a reasonably tight bound reduces number of iterations needed to converge.
I set these upper bounds assuming that a time unit is day.

--fixed[=f,f,f,f,f]:
If you want to fix p by the initial value while performing optimization, please try --fixed=f,t,f,f,f
Order is c,p,alpha,K,mu.

--by_log[=t,f,f,t,t]:
log(c), log(K) and log(mu) are searched instead of c, K and mu since their values can change several orders during optimization.
The default setting seems to reduces number of iterations needed to converge.
You can disable the search-by-log feature by --by-log=f,f,f,f,f
Order is c,p,alpha,K,mu.

--iter_limit[=1000]:
Maximum number of iterations.

--initial_step_size[=-1]:
Maximum initial step size (may be doubled or halved).
If initial_step_size <= 0, it is reset by etas_solve.exe.
EOF
   } >&2
   exit "${1:-1}"
}

option_missing(){
   {
      cat <<EOF
${program_name}: $@ was not specified
EOF
   } >&2
   exit 1
}

readonly dir="${0%/*}"


opts="$(
   getopt \
      --options h \
      --longoptions help,t_pre:,t_begin:,t_end:,t_normalize_len:,m_fit_min:,m_for_K:,c:,p:,alpha:,K:,mu:,data_file:,fixed:,by_log:,lower:,upper:,gtol:,iter_limit:,initial_step_size: \
      --name="$program_name" \
      -- \
      "$@"
)"
eval set -- "$opts"

c=0.01
p=1.1
alpha=0.5
K=1
mu=1
fixed=f,f,f,f,f
by_log=t,f,f,t,t
lower=1d-8,-1,-1,0,1d-8
upper=3,4,5,1d308,1d308
m_fit_min=-1d308
gtol=1d-6
iter_limit=1000
initial_step_size=-1
while true
do
   case "${1}" in
      -h | --help)
         usage_and_exit 0
         ;;
      --t_pre)
         t_pre="$2"
         shift
         ;;
      --t_end)
         t_end="$2"
         shift
         ;;
      --t_begin)
         t_begin="$2"
         shift
         ;;
      --t_normalize_len)
         t_normalize_len="$2"
         shift
         ;;
      --m_fit_min)
         m_fit_min="$2"
         shift
         ;;
      --m_for_K)
         m_for_K="$2"
         shift
         ;;
      --c)
         c="$2"
         shift
         ;;
      --p)
         p="$2"
         shift
         ;;
      --alpha)
         alpha="$2"
         shift
         ;;
      --K)
         K="$2"
         shift
         ;;
      --mu)
         mu="$2"
         shift
            ;;
      --data_file)
         data_file="$2"
         shift
         ;;
      --fixed)
         fixed="$2"
         shift
         ;;
      --by_log)
         by_log="$2"
         shift
         ;;
      --lower)
         lower="$2"
         shift
         ;;
      --upper)
         upper="$2"
         shift
         ;;
      --gtol)
         gtol="$2"
         shift
         ;;
      --iter_limit)
         iter_limit="$2"
         shift
         ;;
      --initial_step_size)
         initial_step_size="$2"
         shift
         ;;
      --)
         shift
         break
         ;;
      *)
         usage_and_exit
         ;;
   esac
   shift
done


[[ -z "${t_normalize_len:-}" ]] && option_missing --t_normalize_len
[[ -z "${m_for_K:-}" ]] && option_missing --m_for_K
[[ -z "${t_pre:-}" ]] && option_missing --t_pre
[[ -z "${t_begin:-}" ]] && option_missing --t_begin
[[ -z "${t_end:-}" ]] && option_missing --t_end
[[ -z "${data_file:-}" ]] && option_missing --data_file


echo "$fixed"
echo "$by_log"
echo "$iter_limit"
echo "$c" "$p" "$alpha" "$K" "$mu"
echo "$lower"
echo "$upper"
echo "$m_fit_min"
echo "$t_begin"
echo "$gtol"
echo "$initial_step_size"
echo "$m_for_K"
echo "$t_normalize_len"
echo "$t_pre"
echo "$t_end"
wc -l "$data_file" | awk '{print $1}'
cat "$data_file"
