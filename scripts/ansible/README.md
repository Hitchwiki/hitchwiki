Since November 2017 (#164) we use [ansible](https://github.com/ansible/ansible) to test and deploy Hitchwiki. It can provision a local vagrant box or deploy a remote server. There is ticket to track issues: #172. Feel free to subscribe and add your reports.

[![Build Status](https://travis-ci.org/Hitchwiki/hitchwiki.svg?branch=master)](https://travis-ci.org/Hitchwiki/hitchwiki)

Table of Contents
=================
<!-- created with https://github.com/ekalinin/github-markdown-toc -->
   * [HOWTO](#howto)
      * [Run in a local Vagrant box](#run-in-a-local-vagrant-box)
      * [Deploy to a new VPS](#deploy-to-a-new-vps)
   * [Reinstall Mediawiki](#reinstall-mediawiki)
   * [Why Ansible?](#why-ansible)
      * [Alternatives / similar](#alternatives--similar)
      * [More](#more)
   * [Tasks](#tasks)
      * [upcoming](#upcoming)
      * [would be nice](#would-be-nice)
      * [later/low prio](#laterlow-prio)
         * [tests](#tests)
            * [travis and docker](#travis-and-docker)
         * [TODOs in code (low prio)](#todos-in-code-low-prio)
         * [ignore_errors: yes mostly is a fallback for something that works](#ignore_errors-yes-mostly-is-a-fallback-for-something-that-works)
      * [MW config](#mw-config)
      * [discourse](#discourse)
      * [matrix](#matrix)
      * [efficient server config](#efficient-server-config)
         * [switch to nginx](#switch-to-nginx)
   * [Ansible notes and snippets](#ansible-notes-and-snippets)
      * [Vagrantfile options](#vagrantfile-options)
      * [Vagrant issues](#vagrant-issues)
      * [Variables](#variables)
      * [handlers](#handlers)
         * [listen and notify](#listen-and-notify)
         * [flush_handlers](#flush_handlers)
      * [conditionals: run tasks based on results of other tasks](#conditionals-run-tasks-based-on-results-of-other-tasks)
      * [turn off logging for secret variable values](#turn-off-logging-for-secret-variable-values)
      * [file globbing](#file-globbing)
      * [callbacks](#callbacks)
      * [Start long running commands like downloads in background](#start-long-running-commands-like-downloads-in-background)

# HOWTO
See [INSTALL.md](https://github.com/traumschule/hitchwiki/blob/ansible/INSTALL.md) and ansible notes below.

## Run in a local Vagrant box
```
git clone https://github.com:traumschule/hitchwiki -b ansible
cd hitchwiki && ./scripts/vagrant/install.sh
# To use apt_cacher on localhost
mkdir host_vars && echo "apt-proxy: localhost" > host_vars/vagrant
# To rerun clean a build
./scripts/vagrant/clean.sh
git reset --hard && git pull
./scripts/vagrant/install.sh
```

## Deploy to a new VPS
```
export remote=HOST
ssh root@$remote # asks for password and requests to change it
./scripts/deploy_remote.sh $remote # adds ssh key, sets up environment and calls `ssh $remote /var/www/scripts/setup_hitchwiki.sh`

# if you already have certificates for production: after wiki setup ansible starts TLS, before do something like:
rsync -aP dumps/letsencrypt.tar.xz $remote:
ssh $remote tar xf letsencrypt.tar.xz && sudo mv etc/letsencrypt/ /etc/
```

## Reinstall Mediawiki
```
rm -r public/wiki
sudo service parsoid stop
./scripts/setup_hitchwiki.sh
```

---

# Why Ansible?
- [easy deployment](https://www.stavros.io/posts/example-provisioning-and-deployment-ansible/)
- [ansible fireball](https://news.ycombinator.com/item?id=5933126)
encryption security](https://news.ycombinator.com/item?id=5933122)
- One important difference: you don't have to install Ansible on the nodes you're managing, just Python >= 2.4 with a JSON module installed (default for 2.6 and later, available through simplejson for previous versions).
- Also, Ansible does not require you to mess around with dependency lists to ensure that packages/files are installed in the right order - the order is built into the yaml config file. You don't lose any capability, you just gain (and this is my personal opinion) ease of understanding the order that operations will occur in.
- Two reports:
> It's ridiculous how much more pleasant it is to use Ansible than Puppet or Chef. Its invention solves a big pain for me: As a veteran user of Puppet I'm a firm believer in using a tool like Puppet, but Puppet-and-Chef are overdesigned for small jobs (and, arguably, for most other jobs as well) so actually recommending them to a beginner has always felt like this:
> A: "I just set up a cloud instance by running some shell commands by hand."
> B: "You shouldn't do that, because of X and Y and Z. You should learn Puppet or Chef."
> A: "Wait... did you just tell me to go spend thirty hours banging my head against solid objects, in exchange for nebulous benefits that I can't even perceive yet?"
> B: "Why, yes, I believe I did!"
> Ansible feels much less embarrassing to advocate.

> After working in Chef for several years and fighting with both gem-rot and managing colliding chef-client and application ruby+rubygems+gem environments with RVM... I was ready for something else. Also, our group just started working alongside another group that does not use cfg management; I wanted something that would be unobtrusive. At first I thought Salt would work, but the minionless mode was not really recommended. You lose a lot of the power of Salt when you do that. Ansible, however, is designed to be minionless. After using it for the last few months, I am (frankly) in love. The last time I felt butterflies like this for a tool was when I grokked git.
> Look, I can maintain my own ansible configurations (inventories, playbooks and roles), and the other groups need not be the wiser. They don't need to worry that servers are going to be reconfigured out from under them, since I am running my configurations explicitly. All they see is that I ssh'd in and did a bunch of stuff really fast. To work with my other groupmates, we just keep the files in git (just flatfiles, yes: just flatfiles). With git I have an audit log of everything that has changed (hosts that have moved environments, configurations that have been updated, etc). And like git it is as distributed as you want it to be. Want to run it from a central server only? Fine. Want to have your admins all run it from their workstations? Fine. Go for it
> Even if the server is ancient or weird (ie. no python), I can still manage it with the raw module.
> Ansible gives me everything I want, with no fuss. It is so basic that I can do things the way I want to.
_[more](https://news.ycombinator.com/item?id=5933025)_

## Alternatives / similar
- [Comparison](https://news.ycombinator.com/item?id=5933349)
- [thread on configuration management] (https://news.ycombinator.com/item?id=5932608) ([post-facto configuration tinkerers' vs. 'Clean-slate, Identifiable Environments](https://news.ycombinator.com/item?id=5933954)) with links to 
  - [vagrant](http://docs.vagrantup.com/v2/why-vagrant/) ([thread](https://news.ycombinator.com/item?id=5933871))
  - [salt](http://docs.saltstack.com/topics/tutorials/quickstart.html): [logrotate module(https://docs.saltstack.com/en/latest/ref/modules/all/salt.modules.logrotate.html), [One-command Django and PostgreSQL development environment on Vagrant](https://github.com/wunki/django-salted)
  - [chef](https://docs.chef.io/resources.html#resources)
  - [puppet](http://docs.puppetlabs.com/learning/index.html) ([thread](https://news.ycombinator.com/item?id=5933641)): _[puppet vs. salt](https://news.ycombinator.com/item?id=5935204)_
  - [zeroMQ](https://news.ycombinator.com/item?id=5933068)
  - [commando.io](https://commando.io/)
  - [AMI](https://news.ycombinator.com/item?id=5934271)
  - [PuPHPet](https://news.ycombinator.com/item?id=5932770] (GUI)
  - [slaughter](https://github.com/skx/slaughter-example) (Perl)
  - [NixOS](https://news.ycombinator.com/item?id=5937371)
  - [foreman](http://theforeman.org/))
  - [pallet](https://news.ycombinator.com/item?id=5934158)
  - [cfengine)[https://cfengine.com/]

## Travis and docker
- official doc(k)s: [docker](https://docs.travis-ci.com/user/docker), [build options(]https://docs.travis-ci.com/user/customizing-the-build), [sdk](https://docs.docker.com/develop/sdk), [images](https://hub.docker.com)
- howtos: [Docker for Admins](https://edenmal.net/2016/04/01/Docker-for-Admins-Workshop-v2), [docker + bluemix](https://ansi.23-5.eu/2017/07/docker-container-bluemix-cli-tools/), [docker composer](https://github.com/heroku/logplex/blob/master/.travis.yml)
As we rely on packages from xenial and travis' still uses [ubunut old-LTS trusty](https://docs.travis-ci.com/user/reference/trusty), docker is our  way to run travis build tests. For ansible it is basically the same as vagrant.
- [multi-platform-tests](https://bertvv.github.io/notes-to-self/2015/12/13/testing-ansible-roles-with-travis-ci-part-2-multi-platform-tests/) ([.travis.yml](https://github.com/weldpua2008/ansible-apache/blob/master/.travis.yml), [centos7](https://stackoverflow.com/questions/32535195/how-to-run-tests-on-centos-7-with-travis-ci))
- [How I test Ansible configuration on 7 different OSes with Docker](https://www.jeffgeerling.com/blog/2016/how-i-test-ansible-configuration-on-7-different-oses-docker) ([examples](https://github.com/geerlingguy/ansible-for-devops), [.travis.yml](https://github.com/geerlingguy/ansible-role-java/blob/1.7.0/.travis.yml))
- alternative init systems: [dumb-init](https://github.com/Yelp/dumb-init)

## More
- [security](https://news.ycombinator.com/item?id=5932823): [VPN and SSH](https://news.ycombinator.com/item?id=5934067)
- [clustering](https://github.com/gyepisam/fcc-textify):  and 
- [Immutable Servers](http://martinfowler.com/bliki/ImmutableServer.html

# Manuals

## MW config
- https://www.mediawiki.org/wiki/Manual:$wgConf
- https://doc.wikimedia.org/mediawiki-core/master/php/interfaceConfig.html

## discourse
- https://meta.discourse.org/t/how-discourse-docker-script-manages-to-autostart-upon-host-machine-reboot/21469/9
-  https://blog.docker.com/2014/08/announcing-docker-1-2-0/
- https://github.com/discourse/discourse/blob/master/docs/INSTALL-email.md
- https://github.com/puma/puma
- https://gist.github.com/surrealroad/5146661
- https://rvm.io/integration/init-d
- https://github.com/rvm/rvm/blob/master/contrib/unicorn_init.sh
- http://blog.daviddollar.org/2011/05/06/introducing-foreman.html
- https://wiki.debian.org/LSBInitScripts/
- https://discourse.stonehearth.net/t/client-server-init-scripts-in-a-deferred-load-mod-are-not-possible/26468/7
- https://github.com/huacnlee/init.d

## matrix
- https://matrix.org/docs/guides/
- https://matrix.org/docs/guides/lets-encrypt.html

## efficient server config
- https://www.speedshop.co/2017/10/12/appserver.html
- https://stackoverflow.com/questions/44635304/apache-not-serving-assets-rails-5-puma-apache-windows-server-2012-r2
- https://meta.discourse.org/t/using-thin-versus-unicorn/8831
- https://github.com/discourse/discourse/commit/613761d1cddcd9e96c418748f0055e6136154bae
- https://www.speedshop.co/2015/07/15/the-complete-guide-to-rails-caching.html
- https://www.railsspeed.com/
- https://appfolio-engineering.squarespace.com/appfolio-engineering/2017/1/31/the-benchmark-and-the-rails
- https://github.com/dariocravero/puma/wiki/Nginx-configuration-example-file

### switch to nginx
- [secure MW confif for nginx](https://www.bonusbits.com/wiki/Reference:Secure_Mediawiki_Nginx_Configuration)

---

# Ansible notes and snippets
- [docs](https://docs.ansible.com), [tutorial](https://serversforhackers.com/c/an-ansible2-tutorial),  [modules](https://docs.ansible.com/ansible/latest/modules_by_category.html), [galaxy](https://galaxy.ansible.com) (examples)
- [FAQ](https://docs.ansible.com/ansible/latest/faq.html), [Q&A](https://serverfault.com/questions/tagged/ansible?page=2&sort=newest&pagesize=15)
- [playbooks](https://docs.ansible.com/ansible/latest/playbooks_reuse.html), [provisioning](https://www.vagrantup.com/docs/provisioning/ansible.html) ([intro](https://www.stavros.io/posts/example-provisioning-and-deployment-ansible/), [ansible.cfg](https://raw.githubusercontent.com/ansible/ansible/devel/examples/ansible.cfg), [tags](https://docs.ansible.com/ansible/latest/playbooks_tags.html), [advanced syntax](https://docs.ansible.com/ansible/latest/playbooks_advanced_syntax.html) (`!unsafe` and alike), [commandline tools](https://docs.ansible.com/ansible/latest/command_line_tools.html)
- changes: [2.4](https://docs.ansible.com/ansible/latest/roadmap/ROADMAP_2_4.html), [staging](https://github.com/ansible/ansible/blob/devel/CHANGELOG.md)
  - [loop](https://github.com/ansible/ansible/blob/d84df2405dc84c1af5d41ddf9c0c2b1d499026f4/docs/docsite/rst/playbooks_loops.rst), [split configs](https://github.com/ansible/proposals/issues/35). [inventory](https://github.com/ansible/proposals/issues/41)

## Vagrantfile options
```
      ansible.fact_caching = "jsonfile"
      ansible.fact_path = "/etc/facts.d/" # https://docs.ansible.com/ansible/latest/intro_configuration.html#fact-path
      #ansible.cfg = "./scripts/ansible/ansible.cfg"
      ansible.roles_path = /opt/mysite/roles:/opt/othersite/roles
      ansible.raw_arguments = ["--log_path=logs/ansible.log --ansible.cfg=ansible.cfg"]
  config.cfg = "./ansible.cfg"
  ENV['ANSIBLE_ROLES_PATH'] = "#{vagrant_root}/infrastructure/provisioning/ansible/roles:#{vagrant_root}/infrastructure/provisioning/ansible/galaxy-roles"
```

## Vagrant issues
- screencast: [Learning Ansible with Vagrant](https://sysadmincasts.com/episodes/45-learning-ansible-with-vagrant-part-2-4)
- /usr/lib/ruby/2.3.0/rubygems/specification.rb:946:in `all=': undefined method `group_by' for nil:NilClass (NoMethodError) => vagrant is too old (prior 1.8.2) and needs to be updated:
```
wget https://releases.hashicorp.com/vagrant/2.0.0/vagrant_2.0.0_x86_64.deb
dpkg -i vagrant_2.0.0_x86_64.deb
```
- [vagrant timeout](https://github.com/cloudfoundry/bosh-lite/issues/306#issuecomment-338847414): Running [vagrant inside VPS on digitalocean](https://www.digitalocean.com/community/tutorials/how-to-use-digitalocean-as-your-provider-in-vagrant-on-an-ubuntu-12-10-vps) costs extra
```
vagrant plugin install vagrant-digitalocean
config.vm.provider :digital_ocean do |provider|
    provider.client_id = "YOUR CLIENT ID"
    provider.api_key = "YOUR API KEY"
    provider.image = "Ubuntu 12.10 x64"
    provider.region = "New York 2"
  end
```

## Variables
- access ansible fact: `{{ ansible_env.SOME_VARIABLE }}`
- access environment variable: `{{ lookup('env','HOME')   ##}}`
- It is possible to save the result of any command in a named register.  This variable will be made available to tasks and templates made further down in the execution flow.
- Registered variables, like facts, are per host. The values can differ depending on the machine.
To access the variable from a different host, you need to go through hostvars, e.g. ${hostvars.foo.time.stdout} should work in your case.
- The shell module makes available variables such as as 'stdout', 'stderr', and 'rc'.
```
    - shell: grep hi /etc/motd
        ignore_errors: yes
register: motd_result
    # alternatively:
      - shell: echo "motd contains the word hi"
        when: motd_result.stdout.find('hi') != -1
      # or also:
      - shell: echo "motd contains word hi"
        when: "'hi' in motd_result.stdout"
```
These variables will be available to subsequent plays during an ansible-playbook run, but will not be saved across executions even if you use a [fact cache](https://docs.ansible.com/ansible/latest/set_fact_module.html).

## handlers
- https://github.com/ansible/proposals/issues/11
### listen and notify
- https://github.com/ansible/ansible/issues/15338
```
- name: notify and flush
  handler:
    - start
    - stop
  flush_handlers: true

- name: restart
  ping:
  changed_when: true
  notify:
  - stop slaves
  - stop master
  - start master
  - start slaves

- name: stop slaves
  command: ...
dependencies:
```

### flush_handlers
- use a handler, and the "force handlers" trick
```
- name: two
  command: /bin/echo one
  when:  whatever_as_needed_could_go_here
  notify:
      - three
- meta: flush_handlers
```

## conditionals: run tasks based on results of other tasks
- https://github.com/ansible/ansible/issues/4297
```
    name: taskA
    register: resultA
    when: conditionA
    name: taskB
    register: resultB
    when: conditionB
    name: combine A and B variables
    set_fact:
    combined_result: "{{ resultA if conditionA else resultB }}"
```
- check for changes: `when: not var2|skipped and var2.changed`

## turn off logging for secret variable values
```
- hosts: all
  no_log: True
- name: secret task
  shell: /usr/bin/do_something --value={{ secret_value }}
  no_log: True
```

## file globbing
```
- name: List all tmp files
  find:
    paths: /tmp/foo
    patterns: "*.tmp"
  register: tmp_glob

- name: Cleanup tmp files
  file:
    path: "{{ item.path }}"
    state: absent
  with_items:
    - "{{ tmp_glob.files }}"
```

## callbacks
If you need a specific exit status, Ansible provides a way to do that via callback plugins.
- https://gist.github.com/cliffano/9868180
- https://stackoverflow.com/questions/20563639/ansible-playbook-shell-output

## Start long running commands like downloads in background
- http://www.linuxnix.com/ansible-run-commands-in-background-in-playbooks
