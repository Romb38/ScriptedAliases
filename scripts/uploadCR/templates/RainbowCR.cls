\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{RainbowCR}[Compte rendu de CR des Rainbow Swingers]

\LoadClass[a4paper]{article}
\RequirePackage[margin=2cm,right=4.5cm, marginparwidth=3cm, marginparsep=0.7cm]{geometry}
\RequirePackage{fontawesome}
\RequirePackage{amsmath}
\RequirePackage{amsfonts}
\RequirePackage{amssymb}
\RequirePackage[french]{babel}
\RequirePackage[shortlabels]{enumitem}
\RequirePackage{array}
\RequirePackage[framemethod=tikz]{mdframed}
\RequirePackage{marginnote}
\RequirePackage{eurosym}
\RequirePackage[bookmarks]{hyperref}

%%%%%%%%%% Hacks divers %%%%%%%%%%%%%%%%%%%%
%\catcode`\·=13 \def\cdottext{\ensuremath\cdot} \let·\cdottext
\let\texteuro\euro

%%%%%%%%%% Version choristes %%%%%%%%%%%%%%%%%%%%
\newif\ifchoristes
%\choristesfalse
\newcommand{\versionchoristes}{\choristestrue}
\newcommand{\onlyCA}[1]{\ifchoristes\else#1\fi}

%%%%%%%%%% Listes %%%%%%%%%%%%%%%%%%%%
\setlist[itemize]{label=\textbullet}
\setlist[itemize,2]{label=$\circ$}

%%%%%%%%%% Title %%%%%%%%%%%%%%%%%%%%
\def\@subtitle{\vspace{-0.8em}}
\newcommand*{\subtitle}[1]{\def\@subtitle{#1}}
\renewcommand{\maketitle}{
    ~\vspace{1cm}
    \noindent\begin{center}
        {\LARGE Compte-rendu de CA~--~Rainbow Swingers (EVUG)}\\
        \vspace{0.4em}
        {\Large \@subtitle~}\\
    \end{center}
    \vspace{2em}

}

%%%%%%%%%% Header %%%%%%%%%%%%%%%%%%%%
\newcommand*{\presents}[1]{\def\@presents{#1}}
\newcommand*{\excuses}[1]{\def\@excuses{#1}}
\newcommand*{\invites}[1]{\def\@invites{#1}}
\newcommand*{\lieu}[1]{\def\@lieu{#1}}
\newcommand*{\horaires}[1]{\def\@horaires{#1}}

\newcommand{\makeheader}{
    \maketitle
    \let\arraystretchbck\arraystretch
    \renewcommand{\arraystretch}{1.3}

    \noindent\begin{minipage}[t]{0.50\textwidth}
        \vspace{0px}
        \begin{tabular}{p{0.25\textwidth} >{\raggedright\arraybackslash}p{0.75\textwidth}}
            \textbf{Présents} & \@presents \\
            \textbf{Excusés} & \@excuses \\
            \textbf{Invités} & \@invites
        \end{tabular}
    \end{minipage}
    \hfill\hfill\vline\hfill
    \begin{minipage}[t]{0.40\textwidth}
        \vspace{0px}
        \begin{tabular}{>{\centering\arraybackslash}p{1em} p{0.9\textwidth}}
            \faicon{calendar} & \@date \\
            \faHome & \@lieu \\
            \faicon{clock-o} & \@horaires \\
        \end{tabular}
    \end{minipage}
    \let\arraystretch\arraystretchbck

    \vspace{2em}
}

%%%%%%%%%% OdJ %%%%%%%%%%%%%%%%%%%%%%

\renewcommand{\contentsname}{Ordre du jour}
\hypersetup{bookmarksdepth=4}
\setcounter{tocdepth}{1}
\newcommand{\odj}{\tableofcontents}

%%%%%%%%%% Tasks %%%%%%%%%%%%%%%%%%%%
\definecolor{taskbarcolor}{RGB}{172,70,255}
\definecolor{tasktextcolor}{RGB}{90,36,132}
\newmdenv[
    linewidth=0.3mm,
    linecolor=taskbarcolor,
    bottomline=false,topline=false,leftline=false,
    rightmargin=-4.3mm,
    innerrightmargin=4mm,
    leftmargin=0pt, innerleftmargin=0pt,
    skipabove=0.5em, innertopmargin=0.3em,
    skipbelow=0.5em, innerbottommargin=0.3em,
]{taskbar}
\newenvironment{task}[1][À définir]{

    \begin{taskbar}%
    \marginnote{\raggedright{}\color{tasktextcolor}%
        \ifchoristes{}\textit{À faire}\else #1 \fi}
}
{
    \end{taskbar}%\ifchoristes\else\end{taskbar}\fi
}
