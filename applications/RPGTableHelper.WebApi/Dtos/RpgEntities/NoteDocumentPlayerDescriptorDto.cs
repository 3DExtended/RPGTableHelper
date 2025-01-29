using System.ComponentModel.DataAnnotations;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;

namespace RPGTableHelper.WebApi.Dtos.RpgEntities;

public class NoteDocumentPlayerDescriptorDto
{
    [Required]
    public User.UserIdentifier UserId { get; set; }

    public string? PlayerCharacterName { get; set; }

    [Required]
    public bool IsDm { get; set; }

    [Required]
    public bool IsYou { get; set; }
}
