"""Least-squares 2D trilateration from simulated anchor ranges."""
import numpy as np
from graph_data import ANCHORS

def trilaterate(distances):
    usable=[(name,distances[name]) for name in ANCHORS if name in distances]
    if len(usable)<3:
        raise ValueError("At least three anchor distances are required.")
    # Linearized circle equations relative to first anchor.
    x0,y0=ANCHORS[usable[0][0]]
    r0=float(usable[0][1])
    A=[]; b=[]
    for name,r in usable[1:]:
        x,y=ANCHORS[name]
        A.append([2*(x-x0),2*(y-y0)])
        b.append(r0*r0-r*r+x*x+y*y-x0*x0-y0*y0)
    solution, *_=np.linalg.lstsq(np.asarray(A,float),np.asarray(b,float),rcond=None)
    return {"x":float(solution[0]+15),"y":float(solution[1]+15)}
