module AzureDevops
  class ListWorkItemsTool < MCP::Tool
    tool_name "list-work-items-tool"
    description "List work items in a project , required: project"

    input_schema(
      properties: {
        project: { type: "string" },
        query: { type: "string" },
        count: { type: "integer" }
      },
      required: ["project"]
    )

    def self.call(server_context:, project:, query: nil, count: 20)
      if project.to_s.strip.empty?
        return ApiClient.error_response("Error: Project parameter is missing or empty.")
      end

      begin
        org = ApiClient.organization
        encoded_project = ApiClient.encode_path(project)

        query = query || "SELECT [System.Id], [System.Title], [System.State], [System.AssignedTo] FROM WorkItems WHERE [System.TeamProject] = '#{project}' ORDER BY [System.Id] DESC"
        url = "https://dev.azure.com/#{org}/#{encoded_project}/_apis/wit/wiql?api-version=7.0"

        result = ApiClient.api_request(:post, url, { query: query })

        return ApiClient.success_response("No work items found") if result["workItems"].nil? || result["workItems"].empty?

        ids = result["workItems"].take(count).map { |wi| wi["id"] }.join(",")
        details_url = "https://dev.azure.com/#{org}/_apis/wit/workitems?ids=#{ids}&api-version=7.0"
        details = ApiClient.api_request(:get, details_url)
      
        work_items = details["value"].map do |wi|
          fields = wi["fields"]
          assigned = fields["System.AssignedTo"]&.dig("displayName") || "Unassigned"
          "- **##{wi['id']}** [#{fields['System.WorkItemType']}] #{fields['System.Title']}\n State: #{fields['System.State']} | Assigned: #{assigned}"
        end.join("\n\n")
      
        ApiClient.success_response("Work Items in #{project}:\n\n#{work_items}")
      rescue => e
        return ApiClient.error_response("Error in ListWorkItemsTool: #{e.message}")
      end
    end
  end
end