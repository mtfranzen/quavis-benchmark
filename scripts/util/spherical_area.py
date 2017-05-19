import numpy as np

# http://mathworld.wolfram.com/SphericalExcess.html

angle = lambda p,q: np.arccos(np.dot(p,q)/np.linalg.norm(p)/np.linalg.norm(q))

p1 = np.asarray([1,1,0])
p2 = np.asarray([-1,1,0])
p3 = np.asarray([0,0.001,1])

a = angle(p1,p2)
b = angle(p2,p3)
c = angle(p3,p1)
s = (a+b+c)/2
print a,b,c

E = 4*np.arctan(np.sqrt(np.tan(0.5*s)*np.tan(0.5*(s-a))*np.tan(0.5*(s-b))*np.tan(0.5*(s-c))))
print E
