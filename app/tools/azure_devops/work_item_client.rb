# azure_devops/work_item_client.rb
module AzureDevops
  class WorkItemClient < ApiClient
    
    # ==================== Work Items ====================

    # def self.list_work_items(project, query = nil, count = 20)
    #   return error_response("Project is required") unless project
      
    #   wiql = query || "SELECT [System.Id], [System.Title], [System.State], [System.AssignedTo] FROM WorkItems WHERE [System.TeamProject] = '#{project}' ORDER BY [System.Id] DESC"
    #   encoded_project = encode_path(project)
    #   url = "https://dev.azure.com/#{organization}/#{encoded_project}/_apis/wit/wiql?api-version=7.0"
    #   result = api_request(:post, url, { query: wiql })
      
    #   return success_response("No work items found") if result["workItems"].nil? || result["workItems"].empty?
      
    #   ids = result["workItems"].take(count).map { |wi| wi["id"] }.join(",")
    #   details_url = "https://dev.azure.com/#{organization}/_apis/wit/workitems?ids=#{ids}&api-version=7.0"
    #   details = api_request(:get, details_url)
      
    #   work_items = details["value"].map do |wi|
    #     fields = wi["fields"]
    #     assigned = fields["System.AssignedTo"]&.dig("displayName") || "Unassigned"
    #     "- **##{wi['id']}** [#{fields['System.WorkItemType']}] #{fields['System.Title']}\n  State: #{fields['System.State']} | Assigned: #{assigned}"
    #   end.join("\n\n")
      
    #   success_response("Work Items in #{project}:\n\n#{work_items}")
    # end

    # def self.get_work_item(id)
    #   return error_response("Work item ID is required") unless id
    #   url = "https://dev.azure.com/#{organization}/_apis/wit/workitems/#{id}?api-version=7.0&$expand=all"
    #   result = api_request(:get, url)
      
    #   fields = result["fields"]
    #   assigned = fields["System.AssignedTo"]&.dig("displayName") || "Unassigned"
    #   desc = (fields["System.Description"] || "No description").gsub(/<[^>]*>/, "")
      
    #   info = [
    #     "**Work Item ##{result['id']}**", "",
    #     "- **Type:** #{fields['System.WorkItemType']}",
    #     "- **State:** #{fields['System.State']}",
    #     "- **Assigned:** #{assigned}",
    #     "", "**Description:**", desc
    #   ].join("\n")
      
    #   success_response(info)
    # end

    # ... (Methods: create_work_item, update_work_item, delete_work_item, add_comment, list_comments) ...
    
    def self.create_work_item(project, work_item_type, title, description, assigned_to, sprint)
      return error_response("Project is required") unless project
      return error_response("Work item type is required") unless work_item_type
      return error_response("Title is required") unless title
      return error_response("Description is required") unless description
      
      encoded_project = encode_path(project)
      url = "https://dev.azure.com/#{organization}/#{encoded_project}/_apis/wit/workitems?api-version=7.0"
      
      body = {
        "op" => "add",
        "path" => "/fields/System.Title",
        "value" => title
      }
      
      result = api_request(:post, url, body)
      
      success_response("Work item created: #{result['id']}")
    end
    
    def self.update_work_item(id, title, description, state, assigned_to, sprint)
      return error_response("Work item ID is required") unless id
      return error_response("Title is required") unless title
      return error_response("Description is required") unless description
      return error_response("State is required") unless state
      return error_response("Assigned to is required") unless assigned_to
      return error_response("Sprint is required") unless sprint
      
      url = "https://dev.azure.com/#{organization}/_apis/wit/workitems/#{id}?api-version=7.0"
      
      body = {
        "op" => "add",
        "path" => "/fields/System.Title",
        "value" => title
      }
      
      result = api_request(:patch, url, body)
      
      success_response("Work item updated: #{result['id']}")
    end
    
    def self.delete_work_item(id)
      return error_response("Work item ID is required") unless id
      url = "https://dev.azure.com/#{organization}/_apis/wit/workitems/#{id}?api-version=7.0"
      api_request(:delete, url)
      success_response("Work item deleted: #{id}")
    end
    
    def self.add_comment(project, work_item_id, comment)
      return error_response("Project is required") unless project
      return error_response("Work item ID is required") unless work_item_id
      return error_response("Comment is required") unless comment
      
      encoded_project = encode_path(project)
      url = "https://dev.azure.com/#{organization}/#{encoded_project}/_apis/wit/workitems/#{work_item_id}/comments?api-version=7.0"
      
      body = {
        "text" => comment
      }
      
      api_request(:post, url, body)
      success_response("Comment added to work item: #{work_item_id}")
    end
    
    def self.list_comments(project, work_item_id)
      return error_response("Project is required") unless project
      return error_response("Work item ID is required") unless work_item_id
      
      encoded_project = encode_path(project)
      url = "https://dev.azure.com/#{organization}/#{encoded_project}/_apis/wit/workitems/#{work_item_id}/comments?api-version=7.0"
      result = api_request(:get, url)
      
      comments = result["value"].map do |comment|
        "#{comment['author']['displayName']} (#{comment['createdDate']})\n#{comment['text']}\n\n"
      end.join("\n\n")
      
      success_response("Comments for work item #{work_item_id}:\n\n#{comments}")
    end
  end
end