gamsQ1.gms --combo=1
gamsQ1.gms --combo=0
gdxmerge *.gdx
gdxdump merged.gdx format=csv symb=profit > profit.csv