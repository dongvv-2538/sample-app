module ApplicationHelper
    #returns the full title on a per-page basis
    def full_title(page_title= '')                              #define the function
        base_title = "Ruby on Rails Tutorial Sample App"        #initialize the base_title variable
        if page_title.empty?                                    #testing boolean of page_title
            base_title                                          #if empty, return base_title only
        else
            "#{page_title} | #{base_title}"                     #otherwise, return page_title | base_title
        end
    end

end
