use DevAssist::Skeleton;
use DevAssist::Skeleton::Raku;
use DevAssist::Skeleton::Debian;

class App::DevAssist {
    method cmd-new(::?CLASS:D:
                   Str:D $name,
                   IO:D $directory,
                   *%kvargs
            --> Bool)
    {
        if $directory.e && $directory.dir {
            warn "{ $directory.Str.raku } already exists!";
            return 1;
        }
        my $skel = DevAssist::Skeleton::Raku.new: |%kvargs, :$directory, :$name;
        return $skel.spurt: |%kvargs;
    }
    method cmd-new-debian(::?CLASS:D:
                   Str $name,
                   IO:D $directory,
                   *%kvargs
            --> Bool)
    {
        if $directory.add('debian').e && $directory.add('debian').dir {
            warn "{ $directory.add('debian').Str.raku } already exists!";
            return 1;
        }
        %kvargs<name> = $_ with $name;
        my $skel = DevAssist::Skeleton::Debian.new: |%kvargs, :$directory;
        return $skel.spurt: |%kvargs;
    }
}
