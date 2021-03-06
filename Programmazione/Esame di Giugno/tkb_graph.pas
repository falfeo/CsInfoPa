unit tkb_graph;

{Graph - Grafi liste concatenate di adiacenza - by TheKaneB

Questa Unit implementa una versione modificata della BFS per
risolvere il problema dei "Pedaggi" della sessione di esami di
Giugno 2007}

interface

uses tkb_pri_queue;
type
    adj_list = ^adj_list_node;
    adj_list_node = record
                  node: integer;
                  next: adj_list;
                  end;
    graph_node_type = boolean; {true = citt� -\\--> false = villaggio}
    graph_node_type_v = array of graph_node_type;
    t_graph = record
            matrix: array of adj_list;
            t: graph_node_type_v;
            end;

procedure graph_init_nodes(var g: t_graph; n: integer);
procedure graph_set_arc(var g: t_graph; i,j: integer);
procedure graph_set_node_type(var g: t_graph; i: integer; t: graph_node_type);
procedure graph_dispose(var g: t_graph);
function graph_get_node_type(g: t_graph; i: integer): graph_node_type;
function graph_get_best_path(g: t_graph; i,j: integer; n:integer): integer;

implementation

{Inizializzazione del grafo, n � il numero dei nodi}
procedure graph_init_nodes(var g: t_graph; n: integer);
var i,j: integer;
begin
     setlength(g.matrix, n);
     setlength(g.t, n);
     for i:=0 to n-1 do begin
         g.t[i] := false;
         g.matrix[i] := nil;
     end;
end;

{Questo grafo � sempre NON orientato, secondo le specifiche dell'esercizio}
procedure graph_set_arc(var g: t_graph; i, j: integer);
var aux: adj_list;
begin
     {Arco i --> j}
     new(aux);
     aux^.node := j;
     aux^.next := g.matrix[i];
     g.matrix[i] := aux;
     
     {Arco j --> i}
     new(aux);
     aux^.node := i;
     aux^.next := g.matrix[j];
     g.matrix[j] := aux;
end;

{Imposta il nodo come citt� o come villaggio}
procedure graph_set_node_type(var g: t_graph; i: integer; t: graph_node_type);
begin
     g.t[i] := t;
end;

{Pulizia dell'heap}
procedure graph_dispose(var g: t_graph);
var i: integer;

    {Procedura ricorsiva interna}
    procedure _dispose(var l: adj_list);
    begin
         if l<>nil then begin
            _dispose(l^.next);
            dispose(l);
            l:=nil;
         end;
    end;

begin
     {Scorre tutte le liste di adiacenza}
     for i:=0 to length(g.matrix)-1 do
         _dispose(g.matrix[i]);
     g.matrix := nil;
     g.t := nil;
end;

{Restituisce il tipo di nodo}
function graph_get_node_type(g: t_graph; i: integer): graph_node_type;
begin
     graph_get_node_type := g.t[i];
end;

{Funzione di ricerca del cammino minimo. Si tratta essenzialmente di
una BFS modificata. Per i dettagli dell'implementazione vedere la relazione.}
function graph_get_best_path(g: t_graph; i, j: integer; n: integer): integer;
var Q: t_pri_queue;
    dist: array of integer;
    idx: integer;
    adj : adj_list;
    last_node: boolean;

    {Funzione peso}
    function _p(x: integer): integer;
    begin
         if graph_get_node_type(g, i) then begin    {Citt�}
            if (x mod 19) = 0 then
               _p := x + (x div 19)
            else
               _p := x + (x div 19) + 1;
         end
         else                                       {Villaggio}
             _p := x + 1;
    end;

begin
     {Inizializzazione}
     setlength(dist, length(g.matrix));
     for idx := 0 to length(dist)-1 do
         dist[idx]:=MAXINT;
     pri_queue_init(Q);
     last_node := FALSE;	

     {Inserisco il nodo di arrivo in coda}
     dist[i] := n;
     pri_queue_push(Q, i, n);

     {BFS}
     while (not pri_queue_empty(Q)) and (not last_node) do begin
     
           {Prelevo un nodo dalla coda}
           i := pri_queue_pop(Q);
	   if i=j then last_node := TRUE;	// Colorazione parziale. Vedi relazione.
           adj := g.matrix[i];
           
           {Scorro la lista degli adiacenti}
           while adj<>nil do begin
                 if dist[adj^.node] > _p(dist[i]) then begin
           
                   {Aggiorna il peso del nodo adiacente}
                   dist[adj^.node] := _p(dist[i]);

                   {Inserisco il nodo adiacente in coda}
                   pri_queue_push(Q, adj^.node, dist[adj^.node]);
                 end;
                 
                 {Passo al successivo adiacente di i}
                 adj := adj^.next;
           end;
     end;
     
     {Pulisco la coda e restituisco la distanza del nodo di partenza j}
     pri_queue_dispose(Q);
     graph_get_best_path := dist[j];
end;

end.

