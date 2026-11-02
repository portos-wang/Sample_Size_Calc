cat("2x2 crossover props in PowerTOST:\n")
d.no <- PowerTOST:::.design.no("2x2")
ades <- PowerTOST:::.design.props(d.no)
print(ades)
# steps=2, bkni=0.5. nc = sum(1/n) = 1/(N/2) + 1/(N/2) = 4/N.
# sem.fac = sqrt(0.5 * 4/N) = sqrt(2/N) !!
cat("sem.fac for N=24:", sqrt(0.5 * (1/12 + 1/12)), "= sqrt(2/N) =", sqrt(2/24), "\n")
