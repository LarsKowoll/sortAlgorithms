%% @author larsk
%% @doc @todo Add description to sort.


-module(sort).

%% ====================================================================
%% API functions
%% ====================================================================

-export([insertionS/1, qsort/3, hsort/1]).

%% ====================================================================
%% Internal functions
%% ====================================================================

%% ======================== Insertionsort =============================

insertionS(Liste) ->
    sortInsertion([], Liste).

%% ====================================================================

sortInsertion(SortierteListe, []) ->
    SortierteListe;

sortInsertion(SortierteListe, [Head|Tail]) ->
    sortInsertion(insert(Head, SortierteListe,[]), Tail).

%% ====================================================================

insert(Element, [Head|SortierteListe], SortierteListeAnfang) when Element > Head ->
    insert(Element, SortierteListe, SortierteListeAnfang++[Head]);

insert(Element, [], SortierteListeAnfang) ->
    SortierteListeAnfang ++ [Element];

insert(Element, SortierteListe, []) ->
    [Element] ++ SortierteListe;

insert(Element, SortierteListe, SortierteListeAnfang) ->
    SortierteListeAnfang ++ [Element] ++ SortierteListe.

%% ====================================================================

%% ======================== Quicksort =================================

qsort(PivotMethode, Liste, SwitchNumber) -> 

    ListenLaenge = getListLength(Liste),
    
    if  
        % Insertionsort      
        (ListenLaenge =< SwitchNumber) ->               
            insertionS(Liste);    

        % Quicksort
        ListenLaenge > SwitchNumber ->            
            Pivot = getPivotElement(PivotMethode, Liste),
            % Pivot wird geloescht
            ListeOhnePivot = Liste -- [Pivot],

            qsort(PivotMethode, smallerList(Pivot, ListeOhnePivot), SwitchNumber) ++ [Pivot] ++ qsort(PivotMethode, largerList(Pivot, ListeOhnePivot), SwitchNumber)           
    end.

%% ====================================================================

smallerList(_, []) ->
    [];

smallerList(Pivot, [Head|Tail]) when Head < Pivot ->
    [Head] ++ smallerList(Pivot, Tail);

smallerList(Pivot, [_|Tail])  ->
    smallerList(Pivot, Tail).

%% ====================================================================

largerList(_, []) ->
    [];

largerList(Pivot, [Head|Tail]) when Head >= Pivot ->
    [Head] ++ largerList(Pivot, Tail);

largerList(Pivot, [_|Tail])  ->
    largerList(Pivot, Tail).


%% ====================================================================

getPivotElement(PivotMethode, Liste) ->
    Laenge = getListLength(Liste),
	HalbeLaengeFloat = Laenge/2,
	HalbeLaenge = util:float_to_int(HalbeLaengeFloat),

    case PivotMethode of
        left -> getFirstElement(Liste);
        middle -> getMiddleElement(Liste, HalbeLaenge);
        right -> getLastElement(Liste);
        median -> getMedianElement(Liste, HalbeLaenge);
        random -> getFirstElement(util:shuffle(Liste))
    end.

%% ====================================================================

getListLength([]) ->
    0;

getListLength([_|Tail]) ->
	1 + getListLength(Tail).

%% ====================================================================

getFirstElement([]) ->       
    [];

getFirstElement([Head|_]) ->
    Head.

%% ====================================================================

getMiddleElement([Head|_], HalbeLaenge) when HalbeLaenge == 1 ->
	Head;

 
getMiddleElement([_|Tail], HalbeLaenge) when HalbeLaenge > 1 ->
	getMiddleElement(Tail, HalbeLaenge-1).

%% ====================================================================

getLastElement([]) ->
    [];

getLastElement([Head|[]]) ->
    Head;

getLastElement([_|Tail]) ->
        getLastElement(Tail).

%% ====================================================================

getMedianElement(Liste, HalbeLaenge) ->

A = getFirstElement(Liste),
B = getMiddleElement(Liste, HalbeLaenge),
C = getLastElement(Liste),

if
    ((A < B) and (B < C)) or ((C < B) and (B < A)) ->
        B;
	
    ((B < C) and (C < A)) or ((A < C) and (C < B)) ->
        C;
	
    ((C < A) and (A < B)) or ((B < A) and (A < C)) ->
        A      
end.

%% ====================================================================

%% ======================== Heapsort ==================================

hsort(Liste) ->
    AnzahlElemente = getListLength(Liste),    
    Heap = reHeap_up(Liste,{},AnzahlElemente),    
    SortierteListe = heapDown(Heap, [], AnzahlElemente),    
    SortierteListe.

%% ====================================================================

reHeap_up([Head|Tail], Baum, Position) ->
    BaumErstellung = insertTree(Head, Baum ,calcPath(Position-length(Tail))),
    reHeap_up(Tail, BaumErstellung, Position);

reHeap_up([], Baum, _) ->
    Baum.

%% ====================================================================

insertTree(Element, {Wurzel, LinkerTeilbaum, RechterTeilbaum}, [r|Tail]) ->
	PfadRechts = insertTree(Element, RechterTeilbaum, Tail),
	Baum = swap(Wurzel, LinkerTeilbaum, PfadRechts),  
	Baum;

insertTree(Element, {Wurzel, LinkerTeilbaum, RechterTeilbaum}, [l|Tail]) ->
	PfadLinks = insertTree(Element, LinkerTeilbaum, Tail),
	Baum = swap(Wurzel, PfadLinks, RechterTeilbaum),  
	Baum;

insertTree(Element, {}, []) ->
    {Element,{},{}}.

%% ====================================================================

swap(Wurzel, {KindknotenLinks, LinkerTeilbaum, RechterTeilbaum}, {}) ->
    if 
		Wurzel > KindknotenLinks ->
        	{Wurzel, {KindknotenLinks, LinkerTeilbaum, RechterTeilbaum},{}};
		
    	true ->
        	{KindknotenLinks, {Wurzel, LinkerTeilbaum, RechterTeilbaum}, {}}
    end;

swap(Wurzel, {KindknotenLinks, LinkerTeilbaumLinks, RechterTeilbaumLinks}, {KindknotenRechts, LinkerTeilbaumRechts, RechterTeilbaumRechts}) when (KindknotenLinks > Wurzel) or (KindknotenRechts > Wurzel) ->
	if 
		KindknotenLinks > KindknotenRechts ->
			{KindknotenLinks,{Wurzel, LinkerTeilbaumLinks, RechterTeilbaumLinks}, {KindknotenRechts, LinkerTeilbaumRechts, RechterTeilbaumRechts}};
		
		true ->
			{KindknotenRechts, {KindknotenLinks, LinkerTeilbaumLinks, RechterTeilbaumLinks}, {Wurzel, LinkerTeilbaumRechts, RechterTeilbaumRechts}}
	
	end;

swap(Wurzel, LinkerTeilbaum, RechterTeilbaum)  ->   
	{Wurzel, LinkerTeilbaum, RechterTeilbaum}.


%% ====================================================================

heapify({Wurzel, {KindknotenLinks, LinkerTeilbaumLinks, RechterTeilbaumLinks}, {KindknotenRechts, LinkerTeilbaumRechts, RechterTeilbaumRechts}}) when (KindknotenLinks > Wurzel) or (KindknotenRechts > Wurzel) ->
	if  
		KindknotenLinks > KindknotenRechts ->
			LinkerTeilbaumNeu  = heapify({Wurzel, LinkerTeilbaumLinks , RechterTeilbaumLinks}),
		    RechterTeilbaumNeu = {KindknotenRechts, LinkerTeilbaumRechts, RechterTeilbaumRechts},
		    {KindknotenLinks, LinkerTeilbaumNeu , RechterTeilbaumNeu};
			
		true ->
		    LinkerTeilbaumNeu  = {KindknotenLinks, LinkerTeilbaumLinks , RechterTeilbaumLinks},
		    RechterTeilbaumNeu = heapify({Wurzel, LinkerTeilbaumRechts, RechterTeilbaumRechts}),
		    {KindknotenRechts, LinkerTeilbaumNeu, RechterTeilbaumNeu}
	
	end;

heapify({Wurzel, {KindknotenLinks, LinkerTeilbaumLinks, RechterTeilbaumLinks}, {}}) when (KindknotenLinks > Wurzel) ->     
    {KindknotenLinks, {Wurzel, LinkerTeilbaumLinks, RechterTeilbaumLinks},{}};

heapify(Baum) ->       
    Baum.

%% ====================================================================

heapDown({Element, {},{}}, SortierteListe, AnzahlElemente) when AnzahlElemente =< 1 ->      
    [Element] ++ SortierteListe;

heapDown(Baum, SortierteListe, AnzahlElemente) ->   
    {Wurzel, _,_} = Baum, 
    Pfad = calcPath(AnzahlElemente),
    KleinsterWert = getWurzel(Baum, Pfad),

    BaumKleinsteWurzel = replaceWurzel(KleinsterWert, delete(Baum, Pfad)),
    Heap = heapify(BaumKleinsteWurzel),

    heapDown(Heap,[Wurzel] ++ SortierteListe, AnzahlElemente-1).

%% ====================================================================

delete({Wurzel, LinkerTeilbaum, RechterTeilbaum}, [r|Tail]) ->
    NeuerTeilbaum = delete(RechterTeilbaum, Tail),
    {Wurzel, LinkerTeilbaum, NeuerTeilbaum};

delete({Wurzel, LinkerTeilbaum, RechterTeilbaum}, [l|Tail]) ->
    NeuerTeilbaum = delete(LinkerTeilbaum, Tail),
    {Wurzel, NeuerTeilbaum, RechterTeilbaum};

delete({}, []) ->    
    {};

delete({_,_,_}, []) ->  
    {}.

%% ====================================================================

replaceWurzel(Wurzel, {}) ->
    {Wurzel, {}, {}};

replaceWurzel(Wurzel, {_,{}, RechterTeilbaum}) ->
    {Wurzel, {}, RechterTeilbaum};

replaceWurzel(Wurzel, {_,LinkerTeilbaum, {}}) ->
    {Wurzel, LinkerTeilbaum, {}};

replaceWurzel(Wurzel, {_,LinkerTeilbaum, RechterTeilbaum}) ->
    {Wurzel, LinkerTeilbaum, RechterTeilbaum}.

%% ====================================================================

getWurzel({_, _, RechterTeilbaum}, [r|Tail]) ->
    getWurzel(RechterTeilbaum, Tail);

getWurzel({_, LinkerTeilbaum, _}, [l|Tail]) ->
     getWurzel(LinkerTeilbaum, Tail);

getWurzel({Wurzel,_,_}, []) ->  
    Wurzel.

%% ====================================================================

% Kodierung des Feldes: Nachfolger von Position i ist 2*i links und 2*i+1 rechts
% berechnet den Pfad zur ersten leeren Position
% l steht fuer links, r fuer rechts
% Beispiel: sort:calcPath(1). --> []
% 		sort:calcPath(2). --> [l]
% 		sort:calcPath(3). --> [r]
% 		sort:calcPath(4). --> [l,l]
% 		sort:calcPath(5). --> [l,r]
% 		sort:calcPath(6). --> [r,l] 
% 		sort:calcPath(7). --> [r,r] 
calcPath(Number) -> calcPath(Number,[]).
% aktuelle Position ist Wurzel
calcPath(1,Accu) -> Accu;
% aktuelle Position ist gerade
calcPath(Number,Accu) when Number rem 2 =:= 0 -> calcPath(Number div 2,[l|Accu]);
% aktuelle Position ist ungerade
calcPath(Number,Accu) when Number rem 2 =/= 0 -> calcPath((Number-1) div 2,[r|Accu]).	


