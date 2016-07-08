Internationalization Automation
====

![Alt text](./internationalization_automation.gif?raw=true "Internationalization Automation")

### Notice / Important
I can't guarantee this script will works fine every time. So you should be careful and always use this tool when you are working on a git branch other than master.

### Why I created this script ?
One of the Roadmap feature that I'm working on (for my company) is related to app internationalization. I have to translate one of our app with chinese language. This stuff can be really long and boring because you have to change manually each hardcoded string and put the reference inside a yml file. In that way, you can easily forget an hardcoded string or replace it with a wrongly reference. As a developer, I thought it could be fun and useful to automate that. I hope this script will help or inspire other developers to automate things.

### How to use this script

* Fork the repository
* Choose the file where the translation should happen. At the moment, only `html.erb` files are allowed
* Choose the `.yml` file where all references will be added.
* Run `ruby translate <path to erb file> <path to yml file>` cmd
* For example inside the script repo, run the cmd below
* `ruby translate ../../rails_projects/ie-events/app/views/contact_form/index.html.erb ../../rails_projects/ie-events/config/locales/views/contact_form/en.yml`. (Notice that you should organize your yml files in that way => config/locales/views/<views folder name>/en.yml|es.yml|zh-CN.yml|...)
* You will see a prompt asking you different questions, you have just to follow instructions
* Once translation is done, you should verify both files to check if nothing went wrong

Enjoy !!!
