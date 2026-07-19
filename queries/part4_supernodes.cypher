//Частина 4 — Виявлення супервузлів. Крок 1. Знайдіть вузли з аномально великою кількістю ребер:
MATCH (n)
WITH n, COUNT { (n)--() } AS degree
ORDER BY degree DESC
LIMIT 10
RETURN labels(n)[0] AS NodeType, 
       coalesce(n.title, n.name, toString(n.userId)) AS NodeName, 
       degree AS NumberOfEdges;