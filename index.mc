<%args>
    $category => ""
    $jahr => ""
    $monat => ""
    $kategorie => ""
    $name => ""
    $kommentar => ""
    $entry_id => ""
    $docid	 => undef 
    $title     => ''
    $text      => ''
    $Save      => undef
    $insert	 => 0
    $showEditor => 0
    $delete => 0
</%args>
<& header.mas &>
<div id="wrapper">
    <div id="content">
% if ($session{logged_in} && $showEditor) {
    <div id="editor" class="entry"><h3>
% if (defined($docid) && ($insert==0)) {
Eintrag <% $docid %> editieren
% } else {
Neuen Eintrag anlegen 
% }
</h3>
% if (length($msg)) {
<p style="color:red;font-size:10px;"><% $msg %></p>
% }
<form name="editform" action="<% $m->request_comp->path() %>" method="post" enctype="application/x-www-form-urlencoded">

<input type="hidden" name="docid" value="<% $docid %>">
<input type="hidden" name="insert" value="<% $insert %>">

<TABLE WIDTH="100%" CELLSPACING=1 CELLPADDING=4 BORDER=0>
<COLGROUP>
<COL ALIGN="right" VALIGN="top">
<COL ALIGN="left">
</COLGROUP>
<TR>
<TD>Titel:</TD>
<TD><input type="text" name="title" value="<% $cgi->escapeHTML($title) %>" size="50" /></TD>
</TR>
<TR>
<TD>Kategorie:</TD>
<TD>
% my @category_titles;
% $dbx{'test'}->select({ fields => 'category_title',
%                         table => 'group2_category',
%                         order => 'category_title ASC'
% });
% while (my $hr = $dbx{'test'}->fetchrow_hashref) {
%     push(@category_titles, $hr->{category_title});
% }
 <select name="kategorie">
% my $i = 1;
% for (my $i=0; $i < scalar @category_titles; $i++) {
    <option><% $category_titles[$i] %></option>
% }
 </select>
 </TD>
</TR>
<TR>
<TD ALIGN=left COLSPAN=2>
% my $FCKeditor = new FCKeditor();
% $FCKeditor->{BasePath} = '/FCKeditor/';
% $FCKeditor->FCKeditor('text');
% $FCKeditor->{Width}          = '100%'; 
% $FCKeditor->{Height}         = 400; 
% $FCKeditor->{Value}          = $text; 
% $FCKeditor->Create();
<BR>
</TD>
</TR>

<TR>
<TD COLSPAN=2 ALIGN=center>
<BR>
<input type="submit" value="Speichern" name="Save">
&nbsp;&nbsp;&nbsp;
<a href="index.mc">Verwerfen</a> <!-- onClick="window.close()" -->
<BR>
<BR>
</TD>
</TR>
</TABLE>

</form>

<%init>
if (!($name eq "") && !($kommentar eq "")) {

# Wir haben versucht, Prepared Statements hinsichtlich SQL Injection zur verwenden.
#my $insertComment = "INSERT INTO comments (entry_id,comment_author,comment_text) VALUES (?,?,?)";
#my $ps=$dbx{'test'}->prepare($insertComment);
#$ps->execute($entry_id,$name,$kommentar);
  
$dbx{'test'}->insert('group2_comment',
        { entry_id => $entry_id,
          comment_id => 0,
          comment_author => $name, 
          comment_text => $kommentar
         });



print "<script>
\$(document).ready(function() {
    \$('#commentbox_". $entry_id ."').show();
});
</script>";
}


print "<script>

\$(document).ready(function() {
    var divHeight = \$(window).height() - 65;
    \$('#wrapper').css('height',divHeight);

});

\$(window).resize(function() {
     var divHeight = \$(window).height() - 65;
    \$('#wrapper').css('height',divHeight);
});

</script>";

use lib qw(/usr/local/test/htdocs/FCKeditor/);
use FCKeditor;

#use POSIX qw(strftime);
#use Time::Local;
use Data::Dumper;

# DB-/strukturierte Daten:
my $dbh = $dbx{'test'};
my $msg = "";

my @category_ids;
    $dbx{'test'}->select({ fields => 'category_id',
                            table => 'group2_category',
                            where => { 'category_title' => [ '=', $kategorie ]}
});
while (my $hr = $dbx{'test'}->fetchrow_hashref) {
    push(@category_ids, $hr->{category_id});
}

if ($delete) {
    # der entfernen button wurde gedrueckt
    $dbx{'test'}->delete({ fields => 'entry_id',
                            table => 'group2_entry',
                            where => { 'entry_id' => [ '=', $docid ]}
    });
}

if ($Save) {
# Speichern wurde gedrückt...
  if ($insert == 1) {
  # Eintrag aus Formularfeldern in Datenbank einfügen
    $dbh->insert( { table  => 'group2_entry',
          	   fields => {
                    'entry_id'         => $docid,
                    'entry_text'       => $text,
                    'entry_title'      => $title,
                    'entry_date'	     => \'NOW()',
                    'category_id'	     => $category_ids[0],
                    'user_id'	         => '1' #TODO
           		}
          	  });
    $msg = "Eintrag $docid neu in DB aufgenommen.";
    $insert = 0;
  } else {
  # Eintrag in Datenbank ändern
    $dbh->update(
          {
            table  => 'group2_entry',
            fields => {
                'entry_text' => $text,
                'entry_title' => $title,
                'category_id' => $category_ids[0]
            },
            where  => { 'entry_id' => $docid }
          } );
    $msg = "Eintrag $docid in DB ver&auml;ndert.";
  }
  # redirect to main page
  print '<meta http-equiv="refresh" content="0; url=index.mc" />';
} elsif ($docid) {
# id erkannt, daten aus Datenbank lesen
  $dbh->select( { fields => "entry_text, entry_title",
		  tables => "group2_entry",
		  where  => { entry_id => $docid }
		}); 
  my $res = $dbh->fetchrow_hashref();
  $title = $res->{entry_title};
  $text = $res->{entry_text};
  $msg = "Eintrag $docid aus DB gelesen.";
} else {
# keine ID, neuen Eintrag erstellen
  $dbh->select( { fields => "max(entry_id) as maxdocid",
		  tables => "group2_entry"
		});
  my $res = $dbh->fetchrow_hashref();
  $docid = $res->{maxdocid}+1;
  $insert = 1;
}

</%init>

<%doc>
</%doc>
</div>
% }
        <& dao/entries.mas, jahr => $jahr, monat => $monat, kategorie => $kategorie &>
        <& sidebar.mas &>
    </div>
    <p id="copyright">&copy; 2013 by Ramon Lopez, Peter Eder, Christian Detamble</p> 
</div>
