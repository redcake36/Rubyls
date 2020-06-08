require 'etc'
require 'optparse'
require 'pp' 

$perm_hash = {"0"=>"---","1"=>"--x","2"=>"-w-","3"=>"-wx","4"=>"r--",
  "5"=>"r-x","6"=>"rw-","7"=>"rwx"}
$ftype_hash = {"file"=>"-", "directory"=>"d", "characterSpecial"=>"c", 
  "blockSpecial"=>"b", "fifo"=>"p", "link"=>"l", "socket"=>"s"}

$dir = "../#{File.basename(Dir.pwd)}"
$ls_var = (Dir.new("../#{File.basename(Dir.pwd)}")).sort - Dir.glob(".*",File::FNM_DOTMATCH) 

$nl = (File.stat(($ls_var.sort {|x,y| File.stat(y).nlink <=> File.stat(x).nlink})[0]).nlink).to_s.size
$sz = (File.stat(($ls_var.sort {|x,y| File.stat(y).size <=> File.stat(x).size})[0]).size).to_s.length

$flags = ""
ARGV.options do |opts|
	opts.on("-l")  {$flags <<("l")}
  opts.on("-a")  {$flags <<("a")}
  opts.on("-r")  {$flags <<("r")}
  opts.on("-t")  {$flags <<("t")}
  opts.on("-R")  {$flags <<("R")}
  opts.parse!
end

def flags_p(str,dir)
  list = (Dir.new("#{dir}")).sort - Dir.glob(".*",File::FNM_DOTMATCH) 
  if str.include?("a")
    la_var = Dir.glob(".*",File::FNM_DOTMATCH)
    la_var.each{ |x| list.push(x)}
    list = list.sort
  end
  if str.include?("t")
    list = list.sort {|x,y| File.stat("#{dir}/#{y}").mtime <=> File.stat("#{dir}/#{x}").mtime} 
  end
  if str.include?("r") 
    list = list.reverse
  end
  if str.include?("l")
    ll_var =[]
    for i in 0..(list.size - 1)
      ll_var.push(ll_str(dir,list[i],$nl,$sz))
    end
    list = ll_var
  end  
  return(list)
end

def ll_str(dir,str,x,y)
  ret = ""
  ret << "#{$ftype_hash[File.ftype("#{dir}/#{str}")]}"
  " #{(File.stat("#{dir}/#{str}").mode.to_s(8)[-3,3]).each_char {|x| ret << $perm_hash[x]}}"
  ret << "#{File.stat("#{dir}/#{str}").nlink}".rjust(x+1)
  ret << " #{Etc.getpwuid(File.stat("#{dir}/#{str}").uid).name }"
  ret << " #{Etc.getgrgid(File.stat("#{dir}/#{str}").gid).name }"
  ret << " #{File.stat("#{dir}/#{str}").size }".rjust(y+1)
  if (File.stat("#{dir}/#{str}").mtime).to_a[5] == Time.now.to_a[5]
    ret << " #{(File.stat("#{dir}/#{str}").mtime).strftime("%b")}"; 
    ret<< " #{(File.stat("#{dir}/#{str}").mtime).day}".rjust(3) ; ret<<"#{(File.stat("#{dir}/#{str}").mtime).to_s[11,5]}".rjust(6)
  else
    ret << " #{(File.stat("#{dir}/#{str}").mtime).strftime("%b")}"; 
    ret<< " #{(File.stat("#{dir}/#{str}").mtime).day}".rjust(3); ret<< "#{(File.stat("#{dir}/#{str}").mtime).year}".rjust(6)
  end
  ret << " #{str}\n"
  return ret
end




def recurs(dir)
  ndir = "#{dir}"
  if $flags.include?("R")
    y = (Dir.new("#{dir}")).sort - Dir.glob(".*",File::FNM_DOTMATCH)
    y.each {|x| if File.directory?("#{dir}/#{x}") 
      single_dir_list = flags_p($flags,"#{dir}/#{x}")
      if $flags.include?("l")
        puts "#{ndir}/#{x}:"
        single_dir_list.each {|x| print "#{x}"}
        puts
      else
        puts "#{ndir}/#{x}:"
        single_dir_list.each {|x| print "#{x}  "}
        puts
        puts
      end
      if File.directory?("#{dir}/#{x}")
        recurs("#{dir}/#{x}")
      end
     end 
    }
  end
end



gotovaii_list = flags_p($flags,$dir)
if $flags.include?("R")
  puts ".:"
  if $flags.include?("l")
    gotovaii_list.each {|x| print "#{x}"}
    puts
  else
    gotovaii_list.each {|x| print "#{x}  "}
    puts
    puts
  end
else
  if $flags.include?("l")
    gotovaii_list.each {|x| print "#{x}"}
  else
    gotovaii_list.each {|x| print "#{x}  "}
    puts
  end
end

recurs($dir)
