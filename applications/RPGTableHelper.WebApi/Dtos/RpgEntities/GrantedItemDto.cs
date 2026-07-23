using System.ComponentModel.DataAnnotations;

namespace RPGTableHelper.WebApi.Dtos.RpgEntities;

/// <summary>
/// A single item grant: <see cref="Amount"/> is added to the character's existing owned amount for
/// <see cref="ItemUuid"/> (creating the inventory entry if it does not exist yet), clamped at a minimum of 0.
/// </summary>
public class GrantedItemDto
{
    [Required]
    public string ItemUuid { get; set; } = default!;

    public int Amount { get; set; }
}
