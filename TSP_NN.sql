CREATE TABLE Vertex (
    vertex_id INT PRIMARY KEY,
    vertex_name VARCHAR(100) NOT NULL
);

CREATE TABLE Edge (
    edge_id INT PRIMARY KEY,
    distance DOUBLE NOT NULL,
    first_vertex_id INT NOT NULL,
    second_vertex_id INT NOT NULL,
    FOREIGN KEY (first_vertex_id) REFERENCES Vertex(vertex_id),
    FOREIGN KEY (second_vertex_id) REFERENCES Vertex(vertex_id),
    CHECK (first_vertex_id != second_vertex_id)  --different starting and ending vertices
);

CREATE TABLE Graph (
    graph_id INT PRIMARY KEY,
    graph_name VARCHAR(100) NOT NULL,
    vertex_count INT NOT NULL,
    edge_count INT NOT NULL
);

CREATE TABLE GraphEdges (
    graph_id INT NOT NULL,
    edge_id INT NOT NULL,
    PRIMARY KEY (graph_id, edge_id),
    FOREIGN KEY (graph_id) REFERENCES Graph(graph_id),
    FOREIGN KEY (edge_id) REFERENCES Edge(edge_id)
);

CREATE TABLE GraphVertices (
    graph_id INT NOT NULL,
    vertex_id INT NOT NULL,
    PRIMARY KEY (graph_id, vertex_id),
    FOREIGN KEY (graph_id) REFERENCES Graph(graph_id),
    FOREIGN KEY (vertex_id) REFERENCES Vertex(vertex_id)
);


CREATE OR REPLACE FUNCTION return_tsp_NN(num_nodes IN INT) RETURN SYS.ODCINUMBERLIST IS
    vertex_ordering SYS.ODCINUMBERLIST := SYS.ODCINUMBERLIST();
    current_vertex_id INT;
    next_vertex_id INT;
    min_distance DOUBLE PRECISION;
    starting_vertex_id INT;
    unvisited_vertices INT;
BEGIN
    -- Clear previous random graph data
    DELETE FROM GraphEdges;
    DELETE FROM GraphVertices;
    DELETE FROM Edge;
    DELETE FROM Vertex;
    DELETE FROM Graph;

    INSERT INTO Graph (graph_id, graph_name, vertex_count, edge_count)
    VALUES (1, 'Random Graph', num_nodes, num_nodes * (num_nodes - 1) / 2);

    FOR i IN 1..num_nodes LOOP
        INSERT INTO Vertex (vertex_id, vertex_name)
        VALUES (i, 'Vertex ' || i);
        INSERT INTO GraphVertices (graph_id, vertex_id)
        VALUES (1, i);
    END LOOP;

    -- Create edges with random distances
    FOR i IN 1..num_nodes LOOP
        FOR j IN i+1..num_nodes LOOP
            INSERT INTO Edge (edge_id, distance, first_vertex_id, second_vertex_id)
            VALUES ((i - 1) * num_nodes + j, DBMS_RANDOM.VALUE(5, 20), i, j);
            INSERT INTO GraphEdges (graph_id, edge_id)
            VALUES (1, (i - 1) * num_nodes + j);
        END LOOP;
    END LOOP;

    -- starting vertex
    SELECT MIN(vertex_id) INTO starting_vertex_id
    FROM GraphVertices
    WHERE graph_id = 1;
    current_vertex_id := starting_vertex_id;

    unvisited_vertices := num_nodes;

    -- Iterate through the vertices to find the nearest neighbor
    WHILE unvisited_vertices > 1 LOOP
        -- find nearest unvisited neighbor
        SELECT MIN(distance) INTO min_distance
        FROM Edge e
        WHERE (e.first_vertex_id = current_vertex_id OR e.second_vertex_id = current_vertex_id)
        AND (e.first_vertex_id IN (SELECT vertex_id FROM GraphVertices WHERE graph_id = 1 AND vertex_id != current_vertex_id)
             OR e.second_vertex_id IN (SELECT vertex_id FROM GraphVertices WHERE graph_id = 1 AND vertex_id != current_vertex_id));

        -- ID of the nearest neighbor
        SELECT CASE
            WHEN e.first_vertex_id = current_vertex_id THEN e.second_vertex_id
            ELSE e.first_vertex_id
        END INTO next_vertex_id
        FROM Edge e
        WHERE (e.first_vertex_id = current_vertex_id OR e.second_vertex_id = current_vertex_id)
        AND (e.first_vertex_id IN (SELECT vertex_id FROM GraphVertices WHERE graph_id = 1 AND vertex_id != current_vertex_id)
             OR e.second_vertex_id IN (SELECT vertex_id FROM GraphVertices WHERE graph_id = 1 AND vertex_id != current_vertex_id))
        AND e.distance = min_distance
        AND ROWNUM = 1;

        vertex_ordering.EXTEND;
        vertex_ordering(vertex_ordering.LAST) := current_vertex_id;

        -- mark the current vertex as visited
        DELETE FROM GraphVertices WHERE graph_id = 1 AND vertex_id = current_vertex_id;
        unvisited_vertices := unvisited_vertices - 1;

        -- Move to the next vertex
        current_vertex_id := next_vertex_id;
    END LOOP;

    -- close the tour by adding the starting vertex again
    vertex_ordering.EXTEND;
    vertex_ordering(vertex_ordering.LAST) := starting_vertex_id;

    RETURN vertex_ordering;
END return_tsp_NN;


CREATE OR REPLACE FUNCTION get_distance(vertex1 IN INT, vertex2 IN INT) RETURN NUMBER IS
    distance NUMBER;
BEGIN
    SELECT distance INTO distance
    FROM Edge
    WHERE (first_vertex_id = vertex1 AND second_vertex_id = vertex2)
       OR (first_vertex_id = vertex2 AND second_vertex_id = vertex1);

    RETURN distance;
END get_distance;




CREATE OR REPLACE FUNCTION swap_ordering_elements(vertex_ordering IN SYS.ODCINUMBERLIST, i IN INT, k IN INT) RETURN SYS.ODCINUMBERLIST IS
    swapped_ordering SYS.ODCINUMBERLIST := vertex_ordering;
    left INT := i;
    right INT := k;
    temp INT;
BEGIN
    WHILE left < right LOOP
        temp := swapped_ordering(left);
        swapped_ordering(left) := swapped_ordering(right);
        swapped_ordering(right) := temp;
        left := left + 1;
        right := right - 1;
    END LOOP;
    RETURN swapped_ordering;
END swap_ordering_elements;




CREATE OR REPLACE FUNCTION apply_2_opt_swap(vertex_ordering IN SYS.ODCINUMBERLIST) RETURN SYS.ODCINUMBERLIST IS
    best_ordering SYS.ODCINUMBERLIST := vertex_ordering;
    best_distance NUMBER := calculate_total_distance(vertex_ordering);
    i INT;
    j INT;
BEGIN
    FOR i IN 2..vertex_ordering.COUNT - 2 LOOP
        FOR j IN i+1..vertex_ordering.COUNT - 1 LOOP
            DECLARE
                new_ordering SYS.ODCINUMBERLIST := swap_ordering_elements(vertex_ordering, i, j);
                new_distance NUMBER := calculate_total_distance(new_ordering);
            BEGIN
                IF new_distance < best_distance THEN
                    best_distance := new_distance;
                    best_ordering := new_ordering;
                END IF;
            END;
        END LOOP;
    END LOOP;

    RETURN best_ordering;
END apply_2_opt_swap;


CREATE OR REPLACE FUNCTION get_original_distance(num_nodes IN INT) RETURN NUMBER IS
    original_distance NUMBER;
BEGIN
    original_distance := calculate_total_distance(return_tsp_NN(num_nodes));
    RETURN original_distance;
END;

CREATE OR REPLACE FUNCTION get_improved_distance(num_nodes IN INT) RETURN NUMBER IS
    tsp_ordering SYS.ODCINUMBERLIST;
    improved_ordering SYS.ODCINUMBERLIST;
    improved_distance NUMBER;
BEGIN

    tsp_ordering := return_tsp_NN(num_nodes);
    improved_ordering := apply_2_opt_swap(tsp_ordering);
    improved_distance := calculate_total_distance(improved_ordering);
    
    RETURN improved_distance;
END;


DECLARE
    tsp_ordering SYS.ODCINUMBERLIST;
    original_distance NUMBER;
    improved_ordering SYS.ODCINUMBERLIST := SYS.ODCINUMBERLIST(); -- Initialize as an empty collection
    improved_distance NUMBER;
BEGIN
    tsp_ordering := return_tsp_NN(10); 
    
    DBMS_OUTPUT.PUT_LINE('Initial TSP Ordering: ');
    FOR i IN 1..tsp_ordering.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE(tsp_ordering(i));
    END LOOP;

    original_distance := calculate_total_distance(tsp_ordering);
    DBMS_OUTPUT.PUT_LINE('Original Total Distance: ' || original_distance);

    improved_ordering := apply_2_opt_swap(tsp_ordering);
    
    improved_distance := calculate_total_distance(improved_ordering);
    
    DBMS_OUTPUT.PUT_LINE('Improved TSP Ordering: ');
    FOR i IN 1..improved_ordering.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE(improved_ordering(i));
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('Improved Total Distance: ' || improved_distance);
END;
