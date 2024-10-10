using RPGTableHelper.DataLayer.Entities.Base;

namespace RPGTableHelper.DataLayer.Entities
{
    public class UserEntity : EntityBase<Guid>
    {
        public string Username { get; set; } = default!;
    }
}
