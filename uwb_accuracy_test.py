"""Run with: python uwb_accuracy_test.py"""
import math
from uwb import simulate_tag_at_node
from trilateration import trilaterate
from graph_data import NAV_NODES, DOORS

def run_accuracy_test(noise_std=0.08):
    nodes={**NAV_NODES,**DOORS}
    errors=[]
    for i,(node,(x,y)) in enumerate(nodes.items()):
        actual=(x+12.5,y+12.5)
        sample=simulate_tag_at_node(node,noise_std,seed=i)
        estimated=trilaterate(sample["distances"])
        errors.append(math.hypot(estimated["x"]-actual[0],estimated["y"]-actual[1]))
    return {"tested_nodes":len(errors),"mean_error":round(sum(errors)/len(errors),2),
            "max_error":round(max(errors),2),"unit":"map coordinate units"}

if __name__=="__main__":
    print(run_accuracy_test())
