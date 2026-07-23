using System.ComponentModel.DataAnnotations;

namespace RPGTableHelper.WebApi.Dtos.RpgEntities;

public class GrantItemsRequestDto
{
    [Required]
    public List<GrantedItemDto> Items { get; set; } = new();
}
