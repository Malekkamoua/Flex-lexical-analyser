%option noyywrap nodefault yylineno case-insensitive
%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    FILE *yyin, *yyout;
    int i,j;
    float reel;
%}


DIGIT    [0-9]
ID       [a-z][a-z0-9]*
CHAINE ["][^"\n]*["]
COMMENTAIRE #(.)+
ESPACE [ \t\n]

EXP ([Ee][-+]?[0-9]+)
%%

{ID}  printf( "IDENT: %s\n", yytext );

{DIGIT}+    {
                printf( "Entier: %s (%d)\n", yytext,
                    atoi( yytext ) );
            }

{DIGIT}+"."{DIGIT}*        {
                printf( " Un réel: %s (%g)\n", yytext,
                        atof( yytext ) );
                }

{DIGIT}+"."{DIGIT}*{EXP}? | {DIGIT}+{EXP}? { 

        /* Decomposition de la chaine pour obtenir une expression mathématique */
        
        i = 0;
		while(i<yyleng && yytext[i] != 'e' && yytext[i] != 'E')
		{
			i++;
		}
		if(yytext[i] == 'e' || yytext[i] != 'E')
		{
			j = yytext[i+1];
			yytext[i] = '\0';
			reel = atof(yytext)*pow(j-48);
		}

        printf("Reel avec exposant %f\n",reel)
    }
    
{CHAINE} { 
            for(i=1;i<yyleng-1;i++) {
                yytext[i-1] = yytext[i];
            }

        /*Marquage fin de chaine*/
            yytext[yyleng-2]='\0'; 
            printf("CHAINE : %s\n",yytext);
         }
         
{COMMENTAIRE} printf("COMMENTAIRE : on ignore\n");


if|then|while|do|else        {
                printf( "Mot Clé: %s\n", yytext );
            }


"+"|"-"|"*"|"/"   printf( "Opérateur arithmétique: %s\n", yytext );

. {
	if(yytext[0]==34) 
	{
		ch="fin de chaine attendue";
	}
	else if(yytext[0]=='-' || yytext[0]=='+' && (yytext[1]<48 || yytext[1]>57 || yytext[1]!=46))
	{
		ch="nombre ou point attendu";
	}
	else
	{
		ch="exposant attendu";
	}
	fprintf(yyout,"%s *** ligne %d *** %s\n",yytext,yylineno,ch);
}

%%

int main(int argc, char *argv[])
{
    /* Passer les fichier pour lecture et ecriture par nom en argument lors l'excecution du code */

    yyin = fopen(argv[1], "r");
    yyout = fopen(argv[2], "w");

    yylex();
    fclose(yyin);
    fclose(yyout);

    return 1;

}
