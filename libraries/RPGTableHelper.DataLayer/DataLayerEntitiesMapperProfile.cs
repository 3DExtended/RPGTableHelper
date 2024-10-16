using AutoMapper;
using Prodot.Patterns.Cqrs;
using Prodot.Patterns.Cqrs.EfCore;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;
using RPGTableHelper.DataLayer.Entities;

namespace RPGTableHelper.DataLayer
{
    public class DataLayerEntitiesMapperProfile : Profile
    {
        public DataLayerEntitiesMapperProfile()
        {
            // User Mappings
            CreateModelMaps<User, User.UserIdentifier, Guid, UserEntity>();

            // EncryptionChallenge Mappings
            CreateMapBetweenIdentifiers<EncryptionChallenge.EncryptionChallengeIdentifier, Guid>();
            CreateMap<EncryptionChallenge, EncryptionChallengeEntity>()
                .ForMember(
                    dest => dest.UserId,
                    opt =>
                        opt.MapFrom(src =>
                            src.UserId.Match<Guid?>((some) => some.Value, () => null)
                        )
                )
                .ReverseMap()
                .ForMember(
                    dest => dest.UserId,
                    opt =>
                        opt.MapFrom(src =>
                            Option.From(
                                !src.UserId.HasValue
                                    ? null
                                    : new User.UserIdentifier { Value = src.UserId.Value }
                            )
                        )
                );

            // UserCredentials Mappings
            CreateMapBetweenIdentifiers<UserCredential.UserCredentialIdentifier, Guid>();
            CreateMap<UserCredential, UserCredentialEntity>()
                .ForMember(
                    dest => dest.EncryptionChallengeId,
                    opt =>
                        opt.MapFrom(src =>
                            src.EncryptionChallengeId.Match<Guid?>((some) => some.Value, () => null)
                        )
                )
                .ForMember(dest => dest.User, opt => opt.Ignore())
                .ForMember(dest => dest.EncryptionChallengeOfUser, opt => opt.Ignore())
                .ForMember(dest => dest.UserId, opt => opt.MapFrom(src => src.UserId.Value))
                .ReverseMap()
                .ForMember(
                    dest => dest.UserId,
                    opt => opt.MapFrom(src => new User.UserIdentifier { Value = src.UserId })
                )
                .ForMember(
                    dest => dest.EncryptionChallengeId,
                    opt =>
                        opt.MapFrom(src =>
                            src.EncryptionChallengeId.ToOptionMapped(
                                (guid) =>
                                    new EncryptionChallenge.EncryptionChallengeIdentifier
                                    {
                                        Value = guid,
                                    }
                            )
                        )
                );
        }

        private void CreateModelMaps<TModel, TIdentifier, TIdentifierValue, TEntity>()
            where TModel : ModelBase<TIdentifier, TIdentifierValue>, new()
            where TIdentifier : Identifier<TIdentifierValue, TIdentifier>, new()
        {
            CreateMapBetweenIdentifiers<TIdentifier, TIdentifierValue>();

            CreateMap<TModel, TEntity>().ReverseMap();
        }

        private void CreateMapBetweenIdentifiers<TIdentifier, TIdentifierValue>()
            where TIdentifier : Identifier<TIdentifierValue, TIdentifier>, new()
        {
            CreateMap<TIdentifier, TIdentifierValue>().ConvertUsing((tmid, _) => tmid.Value);
            CreateMap<TIdentifierValue, TIdentifier>()
                .ConvertUsing((id, _) => Identifier<TIdentifierValue, TIdentifier>.From(id));
        }
    }
}
