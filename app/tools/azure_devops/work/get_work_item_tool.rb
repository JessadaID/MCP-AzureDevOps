module AzureDevops
  class GetWorkItemTool < MCP::Tool
    tool_name "get-work-item-tool"
    description "Get work item details, required: id"

    input_schema(
      properties: {
        id: { type: "integer" }
      },
      required: ["id"]
    )

    def self.call(server_context:, id:)
      if id.to_s.strip.empty?
        return ApiClient.error_response("Error: ID parameter is missing or empty.")
      end

      begin
        org = ApiClient.organization
        url = "https://dev.azure.com/#{org}/_apis/wit/workitems/#{id}?api-version=7.0&$expand=all"
        result = ApiClient.api_request(:get, url)
        
        fields = result["fields"]
        assigned = fields["System.AssignedTo"]&.dig("displayName") || "Unassigned"
        desc = (fields["System.Description"] || "No description").gsub(/<[^>]*>/, "")
        
        info = [
          "**Work Item ##{result['id']}**", "",
          "- **Type:** #{fields['System.WorkItemType']}",
          "- **State:** #{fields['System.State']}",
          "- **Assigned:** #{assigned}",
          "", "**Description:**", desc
        ].join("\n")
        
        ApiClient.success_response(info)
      rescue => e
        return ApiClient.error_response("Error in GetWorkItemTool: #{e.message}")
      end
    end
  end
end