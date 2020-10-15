unit osverticalinterpolation;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

{vertical interpolation}
procedure ODBPr_VertInt(IntLev,LU1,LU2,LD1,LD2,VU1,VU2,VD1,VD2:real;
  var IntVal:real; var Enable:boolean);

function  ODBPr_Line(x0,x1,x2,px1,px2:real) :real;
procedure ODBPr_Lag(x,x1,x2,x3,px1,px2,px3:real; var value:real);
procedure ODBPr_RR(level:real; l_arr,p_arr:array of real;    var value:real);

implementation

(* Процедуры и функции вертикальной интерполяции профилей *)

//линейная по 2 горизонтам
function ODBPr_Line(x0,x1,x2,px1,px2:real) :real;
begin
  if (x1-x2)<>0 then
    ODBPr_Line:=(px1*(x0-x2) - px2*(x0-x1)) / (x1 - x2);
end;

//Лагранж  по 3 горизонтам
procedure ODBPr_Lag(x,x1,x2,x3,px1,px2,px3:real; var value:real);
var
  a1,a2,a3              :real;
  b1,b2,b3,b4,b5,b6     :real;
  y1,y2,y3              :real;
begin
  a1:=x-x1;          a2:=x-x2;          a3:=x-x3;
  b1:=x1-x2;         b2:=x1-x3;
  b3:=x2-x1;         b4:=x2-x3;
  b5:=x3-x1;         b6:=x3-x2;

  if (b1*b2<>0) then y1:=(a2*a3)/(b1*b2);
  if (b3*b4<>0) then y2:=(a1*a3)/(b3*b4);
  if (b5*b6<>0) then y3:=(a1*a2)/(b5*b6);

value:=y1*px1 + y2*px2 + y3*px3;
end;

//Рейнигер-Росс по 4 горизонтам
Procedure ODBPr_RR(level:real; l_arr,p_arr:array of real; var value:real);
var
   kk,k,lev_n:longint;
   col,int_sx,mik_int,rown,ox,coin,check:integer;
   x,x1,x2,x3,x4,px1,px2,px3,px4        :real;
   p,p1,p2                              :real;
   c1,c2                                :real;
   a1,a2,a3,a4                          :real;
   l_12,l_23,l_34                       :real;
   ref                                  :real;
   st_lat                               :real;
   lev_f,lev_l,row_l,u                  :real;
   st                                   :string;
begin
x:=level;

{---uniform profile}
             x1:=l_arr[1];  px1:=p_arr[1];
             x2:=l_arr[2];  px2:=p_arr[2];
             x3:=l_arr[3];  px3:=p_arr[3];
             x4:=l_arr[4];  px4:=p_arr[4];
        if(abs(px1-px2)=0) and
          (abs(px2-px3)=0) and
          (abs(px3-px4)=0) then
          value:=(px2+px3)/2;

{---level coincide}
        coin:=0;
        if(x=x1) then begin value:=px1; coin:=1; end;
        if(x=x2) then begin value:=px2; coin:=1; end;
        if(x=x3) then begin value:=px3; coin:=1; end;
        if(x=x4) then begin value:=px4; coin:=1; end;

{y}     if(coin=0) then begin

{--- If not uniform profile}
        if(abs(px1-px2)>0) or
          (abs(px2-px3)>0) or
          (abs(px3-px4)>0) then
{x}     begin

{--- linearly interpolation}
             l_12:=ODBPr_Line(x,x1,x2,px1,px2);
             l_23:=ODBPr_Line(x,x2,x3,px2,px3);
             l_34:=ODBPr_Line(x,x3,x4,px3,px4);
          {  writeln('line; ',l_12:12:5,l_23:12:5,l_34:12:5);}
          {  readln;}
{--- reference curve}
             a1:=sqr(l_23-l_34)*l_12;
             a2:=sqr(l_12-l_23)*l_34;
             a3:=sqr(l_23-l_34);
             a4:=sqr(l_12-l_23);

                            check:=0;
         if((a3+a4)>0.000001) then check:=1;
            { writeln(a1:10:4,a2:10:4,a3:12:7,a4:12:7);
             writeln'check: ',check:5);}
         case check of
         1: begin  {exclude zero devizion}
             ref:=0.5*( l_23+ ((a1 + a2) / (a3 + a4)) );
{--- parabolic interpolation}
             ODBPr_Lag(x,x1,x2,x3,px1,px2,px3,p1);
             ODBPr_Lag(x,x2,x3,x4,px2,px3,px4,p2);
{--- weighing values}
             a1:=abs((ref-p1))*p2;
             a2:=abs((ref-p2))*p1;
             a3:=abs((ref-p1));
             a4:=abs((ref-p2));
             if (a3+a4)<>0 then value:=(a1+a2)/(a3+a4)
                           else value:=l_23;
     end; {case 1:}
         0:  value:=l_23;
     end; {case}

{x}  end; {if not uniform}
{y}  end; {if level coincide}
end;


procedure ODBPr_VertInt(IntLev,LU1,LU2,LD1,LD2,VU1,VU2,VD1,VD2:real;
                                        var IntVal:real; var Enable:boolean);
var
k:integer;
nu,nd,IntMethod:integer;
h1Limit,h2Limit,h1,h2,h1u,h1d,h2u,h2d:real;
x1,x2,x3,x4,px1,px2,px3,px4,LineVal,pmax,pmin,deviation,rrVal,LagVal:real;
lev_arr,val_arr: array[1..4] of real;
begin
Enable:=false;

   (* update от 10.02.2010 *)
  //lev_arr[1]:=LU2; lev_arr[2]:=LU1; lev_arr[3]:=LD1; lev_arr[4]:=LD2;
  //val_arr[1]:=VU2; val_arr[2]:=VU1; val_arr[3]:=VD1; val_arr[4]:=VD2;
  lev_arr[1]:=LU1; lev_arr[2]:=LU2; lev_arr[3]:=LD1; lev_arr[4]:=LD2;  //AK
  val_arr[1]:=VU1; val_arr[2]:=VU2; val_arr[3]:=VD1; val_arr[4]:=VD2;  //AK


   //определяем пределы интервалов глубин при которых проводится интерполяция
   h1Limit:=5+(1000-5)/3500*IntLev;     {inner limit}
   h2Limit:=200+(1000-200)/3500*IntLev; {upper limit}

   //число горизонтов с наблюдениями выше и ниже стандартного
    nu:=0;
    nd:=0;
    for k:=1 to 2 do if lev_arr[k]<>-9 then nu:=nu+1;
    for k:=3 to 4 do if lev_arr[k]<>-9 then nd:=nd+1;
    //memo1.Lines.Add('nu='+inttostr(nu)+'   nd='+inttostr(nd));

{!}if (nu>0) and (nd>0) then begin

   //разности глубин
     h1:=9999; h2:=9999;
     h2u:=9999; h2d:=9999;
     h1u:=abs(IntLev-lev_arr[2]);
     h1d:=abs(IntLev-lev_arr[3]);
     if nu>1 then h2u:=abs(IntLev-lev_arr[1]);
     if nd>1 then h2d:=abs(IntLev-lev_arr[4]);

     h1:=abs(lev_arr[3]-lev_arr[2]); //inner distance
     if (nu>1) and (nd>1) then
     h2:=abs(lev_arr[4]-lev_arr[1]); //outer distance

     //выбираем метод интерполяции
     //интерполяция проводится если расстояние от интерполируемого
     //до одного из ближайших горизонтов (h1u/h1d) не превышает установленный
     //внутренний предел (h1Limit)

     //интерполяция по 3 точкам используются если растояния от интерполируемого горизонта
     //до выше или ниже лежащей пары горизонтов (h1u,h2u  или h1d,h2d) не выходят
     //за установленные пределы (h1limit,h2Limit)

     //интерполяция по 4 точкам используются если растояния между внутренней и внешней парами
     //ближайших горизонтов не выходят за установленные пределы (h1limit,h2Limit)

     //если полученное нелинейными методами значение не укладывается в диапазон
     //значений параметра на ближайших горизонтах сниженного на 50% (из наибольшего
     //значения вычитается 25% диапазона, к наименьшему прибавляется 25% диапозона)
     //то значение замещается величеной полученной линейным методом

     IntMethod:=1; //Skip Interpolation
     if (h1u<=h1Limit) or (h1d<=h1Limit) then begin
                                                 IntMethod:=3; {  + x +    Linear}
      if (h1<=h1Limit)  and (h2<=h2Limit)  then  IntMethod:=4; {+ + x + +  RR}
      if (h2u<=h2Limit) and (h2d>h2Limit)  then  IntMethod:=5; {+ + x +    LagU}
      if (h2u>h2Limit)  and (h2d<=h2Limit) then  IntMethod:=6; {  + x + +  LagD}
     end;

     //если расстояние между двумя ближайшими горизонтами больше внешнего предела,
     //интерполяция не проводится вообще
     if h1>h2Limit then IntMethod:=1;

     //memo1.Lines.Add('Int Method='+inttostr(IntMethod));


     case IntMethod of
{NO} 1: begin
         Enable:=false;
        end;
{Lin}3: begin
         Enable:=true;
         x1:=lev_arr[2];  px1:=val_arr[2];
         x2:=lev_arr[3];  px2:=val_arr[3];
         IntVal:=ODBPr_Line(IntLev,x1,x2,px1,px2);
        end;
{RR} 4: begin
         Enable:=true;
         x1:=lev_arr[2];  px1:=val_arr[2];
         x2:=lev_arr[3];  px2:=val_arr[3];
         LineVal:=ODBPr_Line(IntLev,x1,x2,px1,px2);
         IntVal:=LineVal;
         {...define nearest max and min}
         if(px1>=px2) then begin pmax:=px1; pmin:=px2; end
                      else begin pmax:=px2; pmin:=px1; end;
         Deviation:=abs(pmax-pmin)*0.25;
         ODBPr_RR(IntLev,lev_arr,val_arr,rrVal);

         //if interpolated value more or less than nearest values
         //and difference with linear int less then 25%
         if(rrVal>pmin) and (rrVal<pmax) and
           (rrVal>LineVal-deviation) and (rrVal<LineVal+deviation)
         then  IntVal:=rrVal;
     end; {4}

{LagUp} 5: begin
          Enable:=true;
            x1:=lev_arr[1];    px1:=val_arr[1];
            x2:=lev_arr[2];    px2:=val_arr[2];
            x3:=lev_arr[3];    px3:=val_arr[3];
            LineVal:=ODBPr_Line(IntLev,x2,x3,px2,px3);
            IntVal:=LineVal;
            {...define nearest max and min}
          if(px2>=px3) then begin pmax:=px2; pmin:=px3; end
                       else begin pmax:=px3; pmin:=px2; end;
            Deviation:=abs(pmax-pmin)*0.25;
            ODBPr_Lag(IntLev,x1,x2,x3,px1,px2,px3,LagVal);

            {...if interpolated value more or less than nearest values}
            if(LagVal>pmin) and (LagVal<pmax) and
              (LagVal>LineVal-deviation) and (LagVal<LineVal+deviation)
            then IntVal:=LagVal;
          end; { case 5:}

{LagDw} 6: begin
           Enable:=true;
            x1:=lev_arr[2];  px1:=val_arr[2];
            x2:=lev_arr[3];  px2:=val_arr[3];
            x3:=lev_arr[4];  px3:=val_arr[4];
            LineVal:=ODBPr_Line(IntLev,x1,x2,px1,px2);
            IntVal:=LineVal;
            {...define nearest max and min}
           if(px1>=px2) then begin pmax:=px1; pmin:=px2; end
                        else begin pmax:=px2; pmin:=px1; end;
            Deviation:=abs(pmax-pmin)*0.25;
            ODBPr_Lag(IntLev,x1,x2,x3,px1,px2,px3,LagVal);
            if(LagVal>pmin) and (LagVal<pmax) and
              (LagVal>LineVal-deviation) and (LagVal<LineVal+deviation)
            then IntVal:=LagVal;
         end; {6}
     end; {case}
{!}end;
end;

end.

