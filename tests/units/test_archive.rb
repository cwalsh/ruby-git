#!/usr/bin/env ruby

require File.dirname(__FILE__) + '/../test_helper'
require 'rubygems/package'

class TestArchive < Test::Unit::TestCase
  
  def setup
    set_file_paths
    @git = Git.open(@wdir)
  end
  
  def tempfile
    Tempfile.new('archive-test').path
  end

  def archive_files(filename)
    files = []
    archive = File.open(filename)
    tar = Gem::Package::TarReader.new(archive)
    tar.each { |entry| files << entry.full_name }
    tar.close
    archive.close
    files[1..-1] #The first element is a Tar header
  end
  
  def test_archive
    f = @git.archive('v2.6', tempfile)
    assert(File.exists?(f))

    f = @git.object('v2.6').archive(tempfile)  # writes to given file
    assert(File.exists?(f))

    f = @git.object('v2.6').archive # returns path to temp file
    assert(File.exists?(f))
    
    f = @git.object('v2.6').archive(nil, :format => 'tar') # returns path to temp file
    assert(File.exists?(f))
    
    files = archive_files f
    assert_equal('ex_dir/', files[0])
    assert_equal('example.txt', files[2])
    
    f = @git.object('v2.6').archive(tempfile, :format => 'zip')
    assert(File.file?(f))

    f = @git.object('v2.6').archive(tempfile, :format => 'tgz', :prefix => 'test/')
    assert(File.exists?(f))
    
    f = @git.object('v2.6').archive(tempfile, :format => 'tar', :prefix => 'test/', :path => 'ex_dir/')
    assert(File.exists?(f))
    
    files = archive_files f
    assert_equal('test/', files[0])
    assert_equal('test/ex_dir/ex.txt', files[2])

    in_temp_dir do
      c = Git.clone(@wbare, 'new')
      c.chdir do
        f = @git.remote('origin').branch('master').archive(tempfile, :format => 'tgz')
        assert(File.exists?(f))
      end
    end
  end
  
end
