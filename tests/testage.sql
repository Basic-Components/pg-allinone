SELECT * FROM ag_catalog.create_graph('graph_name');

SELECT * FROM ag_catalog.cypher('graph_name', $$CREATE (:Person {name: 'John'}),(:Person {name: 'Jeff'}),(:Person {name: 'Joan'}),(:Person {name: 'Bill'})$$) AS (result agtype);

SELECT * FROM ag_catalog.cypher('graph_name', $$
	MATCH (v:Person)
	WHERE v.name STARTS WITH "J"
	RETURN v.name
$$) AS (names agtype);


SELECT * FROM ag_catalog.cypher('graph_name', $$
	MATCH (v:Person)
	WHERE v.name CONTAINS "o"
	RETURN v.name
$$) AS (names agtype);

SELECT * FROM ag_catalog.cypher('graph_name', $$
	MATCH (v:Person)
	WHERE v.name ENDS WITH "n"
	RETURN v.name
$$) AS (names agtype);

SELECT * FROM ag_catalog.drop_graph('graph_name', true);