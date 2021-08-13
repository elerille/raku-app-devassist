use DevAssist::Skeleton;
unit class DevAssist::Skeleton::Debian does DevAssist::Skeleton;

use META6;
use META6::Depends;

has Str $.name;
has IO:D $.debian = $!directory.add('debian');
has UInt $.revision = 1;

has Str:D $.fullname = %*ENV<DEBFULLNAME> // %*ENV<FULLNAME>;
has Str:D $.username = %*ENV<LOGNAME> // %*ENV<USER> // $*USER;
has Str:D $.email = %*ENV<DEBEMAIL> // %*ENV<EMAIL>;

has Bool:D $.strict = False;
has Str:D $.section = $!strict ?? 'interpreters' !! 'raku';
has Version:D $.standards-version = v4.5.1;

submethod TWEAK {
    $!name //= do if $!directory.add("META6.json").e {
        self.module-name-to-debian(META6.new(file => $!directory.add("META6.json")).name)
    } else {
        self.module-name-to-debian($!directory.absolute.IO.basename)
    }
}

method spurt(::?CLASS:D: --> Bool:D) {
    say "Debname = $!name";
    $!debian.mkdir;
    my Bool:D $res = True;
    $res &&= self.spurt-debian-changelog;
    $res &&= self.spurt-debian-copyright;
    $res &&= self.spurt-debian-rules;
    $res &&= self.spurt-debian-readme_source;
    $res &&= self.spurt-debian-readme_debian;
    $res &&= self.spurt-debian-control;
    $res;
}

method spurt-debian-changelog(::?CLASS:D: --> Bool:D) {
    my $file-name = $!debian.add('changelog');
    my $meta = META6.new: file => $!directory.add('META6.json');
    my IO::Handle:D $fh = $file-name.open(:w);
    $fh.say: sprintf "%s (%s) %s; urgency=%s",
            $!name,
            $meta.version ~ "-" ~ $!revision,
            'UNRELEASED',
            'medium';
    $fh.say;
    $fh.say: "  * Initial release (Closes: #nnnn)  <nnnn is the bug number of your ITP>";
    $fh.say;
    $fh.say: sprintf " -- %s <%s>  %s", $!fullname, $!email, DateTime.now(:&formatter);
    True
}
method spurt-debian-copyright(::?CLASS:D: --> Bool:D) {
    my $meta = META6.new: file => $!directory.add('META6.json');
    my IO::Handle:D $fh = $!debian.add('copyright').open(:w);
    my $upstream-contact =
            do if $meta.auth ~~ /^ .+ "<" .+ "@" .+ ">" $/ { $meta.auth }
            elsif $meta.authors[0] ~~ /^ .+ "<" .+ "@" .+ ">" $/ { $meta.authors[0] }
            elsif $meta.authors[0].defined && $meta.support.email.defined {
                $meta.authors[0] ~ " <" ~ $meta.support.email ~ ">"
            } elsif $meta.auth.defined && $meta.support.email.defined {
                $meta.auth ~ " <" ~ $meta.support.email ~ ">"
            } else { "<preferred name and address to reach the upstream project>" }
    my $license-name = $meta.license // $meta.support.license // "UNKNOWN";
    $license-name ~= '-other' if $license-name eq "GPL-3.0+";
    my $license-text;
    if 'LICENSE'.IO.e {
        $license-text = 'LICENSE'.IO.slurp.indent(1).subst("\t", "  ", :g).subst(/^^ \s* $$/, " .", :g);
    } elsif 'COPYING'.IO.e {
        $license-text = 'COPYING'.IO.slurp.indent(1).subst("\t", "  ", :g).subst(/^^ \s* $$/, " .", :g);
    }

    $fh.say: "Format: https://www.debian.org/doc/packaging-manuals/copyright-format/1.0/";
    $fh.say: "Upstream-Name: { $meta.name }";
    $fh.say: "Upstream-Contact: $upstream-contact";
    $fh.say: "Source: { $meta.support.source // $meta.source-url }";
    $fh.say;
    $fh.say: "Files: *";
    $fh.say: "Copyright: <years> <put author's name and email here>";
    $fh.say: "           <years> <likewise for another author>";
    $fh.say: "License: $license-name";
    $fh.say;
    $fh.say: "Files: debian/*";
    $fh.say: "Copyright: { Date.today.year } $!fullname <$!email>";
    $fh.say: "License: GPL-3.0+";
    $fh.say;
    $fh.say: "License: GPL-3.0+";
    $fh.say: qq:to/END/;
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 .
 This package is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 .
 You should have received a copy of the GNU General Public License
 along with this program. If not, see <https://www.gnu.org/licenses/>.
 .
 On Debian systems, the complete text of the GNU General
 Public License version 3 can be found in "/usr/share/common-licenses/GPL-3".
END

    with $license-text {
        $fh.say: "License: $license-name";
        $fh.say: $_;
    }
    $fh.say: q:to/END/;
# Please also look if there are files or directories which have a
# different copyright/license attached and list them here.
# Please avoid picking licenses with terms that are more restrictive than the
# packaged work, as it may make Debian's contributions unacceptable upstream.
#
# If you need, there are some extra license texts available in two places:
#   /usr/share/debhelper/dh_make/licenses/
#   /usr/share/common-licenses/
END

    True
}
method spurt-debian-rules(::?CLASS:D: --> Bool:D) {
    my $file-name = $!debian.add('rules');
    $file-name.spurt: q:to/END/;
#!/usr/bin/make -f

%:
	dh $@ --with perl6

END

    run <chmod +x>, $file-name;
    True
}

method spurt-debian-readme_source(::?CLASS:D: --> Bool:D) {
    my $meta = META6.new: file => $!directory.add('META6.json');
    my IO::Handle:D $fh = $!debian.add('README.source').open(:w);
    my $title = $meta.name ~ " for Debian";
    $fh.say: $title;
    $fh.say: '-' x $title.chars;
    $fh.say;
    $fh.say: '<this file describes information about the source package, see Debian policy';
    $fh.say: 'manual section 4.14. You WILL either need to modify or delete this file>';
    $fh.say;
    $fh.say;
    $fh.say;
    $fh.say: sprintf " -- %s <%s>  %s", $!fullname, $!email, DateTime.now(:&formatter);
    $fh.say;
    True
}

method spurt-debian-readme_debian(::?CLASS:D: --> Bool:D) {
    my $meta = META6.new: file => $!directory.add('META6.json');
    my IO::Handle:D $fh = $!debian.add('README.Debian').open(:w);
    my $title = $meta.name ~ " for Debian";
    $fh.say: $title;
    $fh.say: '-' x $title.chars;
    $fh.say;
    $fh.say: '<possible notes regarding this package - if none, delete this file>';
    $fh.say;
    $fh.say: sprintf " -- %s <%s>  %s", $!fullname, $!email, DateTime.now(:&formatter);
    $fh.say;
    True
}
method spurt-debian-control(::?CLASS:D: --> Bool:D) {
    my $meta = META6.new: file => $!directory.add('META6.json');
    #    if $file-name.IO.e { return False }
    my IO::Handle:D $fh = $!debian.add('control').open(:w);

    my @Depends = 'rakudo', '${misc:Depends}';
    my @Pre-Depends;
    my @Recommends;
    my @Suggests;
    my @Enhances;
    my @Breaks;
    my @Conflicts;
    my @Provides;
    my @Build-Depends = 'debhelper-compat (= 13)', 'dh-perl6';
    @Build-Depends.push: 'perl6-tap-harness' if $!directory.add('t').e;
    my @Build-Depends-Indep;
    my @Build-Depends-Arch;
    my @Build-Conflicts;
    my @Build-Conflicts-Indep;
    my @Build-Conflicts-Arch;
    my @Replaces;

    #| %depends<runtime>
    #| %depends<build>
    #| %depends<test>
    #| %depends<*><requires>
    #| %depends<*><recommends>
    my %depends = META6::Depends.from-meta($meta);
    for %depends.kv -> $phase, $_ { for .kv -> $level, $_ { for @$_ {
        my $dep = $_.Seq.map(-> $dep {
            my $name = do given $dep.from {
                when 'raku' { self.module-name-to-debian($dep.name) }
                when 'native' {
                    note "Find lib", $dep.name, ".so";
                    my @list = run(<apt-file find -lx>, '/lib' ~ $dep.name ~ '.so(.\\d+)*$', :out).out.slurp(:close)
                            .lines;
                    my $depname = $dep.name;
                    my @best-list = @list.grep(/^ lib $depname [\d+]* % '.' $/);
                    if  @best-list { @best-list.sort.tail }
                    else { 'lib' ~ $dep.name ~ '.so:from' ~ @list.raku }
                }
                when 'bin' {
                    note "Find ", $dep.name;
                    my @list = run(<apt-file find -lx>, '/' ~ $dep.name ~ '$', :out).out.slurp(:close).lines;
                    if $dep.name ∈ @list { $dep.name }
                    else { $dep.name ~ ":from" ~ @list.raku }
                }
                default { ... }
            }
            my @vers = do for ^+$dep.ver { $dep.cmp[$_] ~ ' ' ~ $dep.ver[$_] }
            if @vers { $name ~ ' (' ~ @vers.join(' && ') ~ ')' }
            else { $name }
        }).join(' | ');
        given $phase, $level {
            when 'runtime', 'requires' { @Depends.push: $dep }
            when 'runtime', 'recommends' { @Recommends.push: $dep }
            when 'test' | 'build', * { @Build-Depends.push: $dep }
            default { ... }
        }
    } } }
    @Build-Depends.push: |@Depends if $!directory.add('t').e;



    $fh.say: "Source: $!name";
    $fh.say: "Maintainer: $!fullname <$!email>";
    #$fh.say: "Uploaders: $!fullname <$!email>";
    $fh.say: "Section: $!section";
    $fh.say: "Priority: optional";
    $fh.say: "Standards-Version: $!standards-version";
    for (:@Build-Depends, :@Build-Depends-Indep, :@Build-Depends-Arch,
         :@Build-Conflicts, :@Build-Conflicts-Indep, :@Build-Conflicts-Arch) {
        $fh.say: .key, ": ", .value.sort.join(",\n ") if .value;
    }
    $fh.say: "Homepage: <insert the upstream URL, if relevant>";
    $fh.say: "Rules-Requires-Root: no";
    $fh.say;
    $fh.say: "Package: { self.module-name-to-debian: $meta.name }";
    $fh.say: "Architecture: all";
    for (:@Depends, :@Pre-Depends, :@Recommends, :@Suggests, :@Enhances, :@Breaks, :@Conflicts, :@Provides, :@Replaces) {
        $fh.say: .key, ": ", .value.sort.join(",\n ") if .value;
    }
#    $fh.say: "Depends: ", $_.sort.join(",\n ") with @Depends;
#    $fh.say: "Pre-Depends: ", $_.sort.join(",\n ") with @Pre-Depends;
#    $fh.say: "Recommends: ", $_.sort.join(",\n ") with @Recommends;
#    $fh.say: "Suggests: ", $_.sort.join(",\n ") with @Suggests;
#    $fh.say: "Enhances: ", $_.sort.join(",\n ") with @Enhances;
#    $fh.say: "Breaks: ", $_.sort.join(",\n ") with @Breaks;
#    $fh.say: "Conflicts: ", $_.sort.join(",\n ") with @Conflicts;
#    $fh.say: "Provides: ", $_.sort.join(",\n ") with @Provides;
#    $fh.say: "Replaces: ", $_.sort.join(",\n ") with @Replaces;
    $fh.say: "Description: ", $meta.description;
    $fh.say: ' <insert long description, indented with spaces>';
    $fh.say: ' .';
    $fh.say: ' Provides:';
    $fh.say: "  - $_" for $meta.provides.keys.sort;
    $fh.say: ' .';
    $fh.say: ' This description was automagically extracted from the module by dh-make-perl.';

    #    say $meta.to-json: :sorted-keys;
    #    say $meta.support;
    True
}

method module-name-to-debian(::?CLASS:_:
                             Str:D $_
        --> Str:D)
{
    "raku-" ~ $_.lc
            .subst(/'::' | <[\ /\n_]>/, '-', :global)
            .subst(/<-[a..z0..9+.-]>/, '', :global)
            .subst(/"-"+/, '-', :global)
            .subst(/^"-"/, "")
}



sub formatter(DateTime:D $_ --> Str:D) {
    sprintf "%s, %02d %s %4d %s %+03d%02d",
            <Mon Tue Wed Thu Fri Sat Sun>[.day-of-week - 1],
            .day,
            <Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec>[.month - 1],
            .year,
            .hh-mm-ss,
            .offset-in-hours, .offset-in-minutes % 60;
            ;
}
