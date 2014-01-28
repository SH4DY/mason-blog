Database Connection Test

Result set 1
<UL>
% foreach my $result (@result1) {
 <LI> <% $result%>
% }
</UL>

Result set 2
% foreach my $result (@result2) {
 <LI> <% $result%>
% }
</UL>

<%init>
  $dbx{'iss2'}->select({ fields => 'entry_id, entry_title',
                         table => 'entries',
			 where => {}
                       });
  my @result1;
  while (my $hr = $dbx{'iss2'}->fetchrow_hashref) {
    push(@result1, "$hr->{'entry_date'}...$hr->{'entry_title'}");
  }

  $dbx{'iss2'}->select({ fields => 'entry_id, entry_title',
                         table => 'entries',
			 where => {'entry_id' => [ '>','1' ]}
                       });
  my @result2;
  while (my $hr = $dbx{'iss2'}->fetchrow_hashref) {
    push(@result2, "$hr->{'entry_date'}...$hr->{'entry_title'}");
  }
</%init>